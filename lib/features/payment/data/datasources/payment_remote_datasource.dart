import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../../core/utils/logger.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

/// Remote data source for [PaymentModel]. Talks to the Supabase
/// `payments` table directly. In test mode all operations run against
/// an in-memory map keyed by payment id so the rest of the stack
/// behaves like a real backend without any network round-trips.
abstract class PaymentRemoteDataSource {
  Future<PaymentModel> createPayment(CreatePaymentParams params);
  Future<PaymentStatus> getPaymentStatus(String paymentId);
  Stream<PaymentStatus> watchPaymentStatus(String paymentId);
  Future<List<PaymentModel>> getUserPayments(String userId);
  Future<PaymentModel> cancelPayment(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final supabase.SupabaseClient _supabase;
  final Uuid _uuid;

  /// In-memory store used while [TestConfig.isTestMode] is on.
  /// Mock gateway services mutate the same map to simulate webhook updates.
  static final Map<String, PaymentModel> _testStore = {};

  /// Test-mode hook: lets a mock gateway service flip the status of a stored
  /// payment without going through Supabase. Returns the updated model, or
  /// `null` if the id isn't tracked.
  static PaymentModel? updateTestPaymentStatus(
    String paymentId,
    PaymentStatus status, {
    String? checkoutUrl,
  }) {
    final existing = _testStore[paymentId];
    if (existing == null) return null;
    final updated = PaymentModel.fromEntity(
      existing.copyWith(
        status: status,
        checkoutUrl: checkoutUrl ?? existing.checkoutUrl,
        completedAt: status.isTerminal ? DateTime.now() : existing.completedAt,
      ),
    );
    _testStore[paymentId] = updated;
    return updated;
  }

  PaymentRemoteDataSourceImpl({
    required supabase.SupabaseClient supabaseClient,
    Uuid? uuid,
  })  : _supabase = supabaseClient,
        _uuid = uuid ?? const Uuid();

  @override
  Future<PaymentModel> createPayment(CreatePaymentParams params) async {
    if (TestConfig.isTestMode) {
      AppLogger.info(
        'TEST MODE: Creating payment '
        '(${params.productType.value}, ${params.amount} ${params.currency})',
      );
      await Future.delayed(const Duration(milliseconds: 500));

      final id = _uuid.v4();
      final now = DateTime.now();
      final model = PaymentModel(
        id: id,
        userId: _supabase.auth.currentUser?.id ?? 'test_user',
        amount: params.amount,
        currency: params.currency,
        status: PaymentStatus.pending,
        gateway: params.gateway,
        productType: params.productType,
        productId: params.boostPackageId,
        billingCycle: params.billingCycle,
        seatCount: params.seatCount,
        plan: params.plan,
        createdAt: now,
      );
      _testStore[id] = model;
      return model;
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final now = DateTime.now().toIso8601String();
      final data = <String, dynamic>{
        'user_id': currentUser.id,
        'amount': params.amount,
        'currency': params.currency,
        'status': PaymentStatus.pending.value,
        'gateway': params.gateway.value,
        'product_type': params.productType.value,
        'product_id': params.boostPackageId,
        'billing_cycle': params.billingCycle?.value,
        'seat_count': params.seatCount,
        'plan': params.plan?.name,
        'metadata': const <String, dynamic>{},
        'created_at': now,
      };

      final response = await _supabase
          .from(ApiEndpoints.payments)
          .insert(data)
          .select()
          .single();

      AppLogger.info('Payment created: ${response['id']}');
      return PaymentModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error creating payment', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.AuthException) rethrow;
      AppLogger.error('Error creating payment', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    if (TestConfig.isTestMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final model = _testStore[paymentId];
      if (model == null) {
        throw const app_exceptions.NotFoundException(
          message: 'Payment not found',
          resource: 'payment',
        );
      }
      return model.status;
    }

    try {
      final response = await _supabase
          .from(ApiEndpoints.payments)
          .select('status')
          .eq('id', paymentId)
          .single();

      return PaymentStatus.fromString(response['status'] as String? ?? 'pending');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error reading payment status', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.NotFoundException) rethrow;
      AppLogger.error('Error reading payment status', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  /// Polling stream — re-reads status every 2 seconds until a terminal
  /// state is reached, then closes. Errors propagate as stream errors;
  /// the repository converts them to [Left(Failure)] for the bloc.
  @override
  Stream<PaymentStatus> watchPaymentStatus(String paymentId) async* {
    const interval = Duration(seconds: 2);
    while (true) {
      final status = await getPaymentStatus(paymentId);
      yield status;
      if (status.isTerminal) {
        return;
      }
      await Future.delayed(interval);
    }
  }

  @override
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Listing payments for $userId');
      await Future.delayed(const Duration(milliseconds: 500));
      final list = _testStore.values
          .where((p) => p.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    try {
      final response = await _supabase
          .from(ApiEndpoints.payments)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error listing payments', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      AppLogger.error('Error listing payments', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<PaymentModel> cancelPayment(String paymentId) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Cancelling payment $paymentId');
      await Future.delayed(const Duration(milliseconds: 500));
      final existing = _testStore[paymentId];
      if (existing == null) {
        throw const app_exceptions.NotFoundException(
          message: 'Payment not found',
          resource: 'payment',
        );
      }
      final updated = PaymentModel.fromEntity(
        existing.copyWith(
          status: PaymentStatus.cancelled,
          completedAt: DateTime.now(),
        ),
      );
      _testStore[paymentId] = updated;
      return updated;
    }

    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from(ApiEndpoints.payments)
          .update({
            'status': PaymentStatus.cancelled.value,
            'completed_at': now,
          })
          .eq('id', paymentId)
          .select()
          .single();

      AppLogger.info('Payment cancelled: $paymentId');
      return PaymentModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error cancelling payment', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      AppLogger.error('Error cancelling payment', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }
}
