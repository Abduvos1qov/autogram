import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/repositories/seller_repository.dart';
import '../../domain/usecases/upgrade_to_seller_usecase.dart';
import 'seller_event.dart';
import 'seller_state.dart';

/// Seller BLoC

class SellerBloc extends Bloc<SellerEvent, SellerState> {
  final SellerRepository _repository;
  final UpgradeToSellerUseCase _upgradeToSellerUseCase;

  SellerBloc({
    required SellerRepository repository,
    required UpgradeToSellerUseCase upgradeToSellerUseCase,
  })  : _repository = repository,
        _upgradeToSellerUseCase = upgradeToSellerUseCase,
        super(const SellerState()) {
    on<SellerProfileLoadRequested>(_onProfileLoadRequested);
    on<SellerBusinessTypeSelected>(_onBusinessTypeSelected);
    on<SellerBusinessInfoUpdated>(_onBusinessInfoUpdated);
    on<SellerPlanSelected>(_onPlanSelected);
    on<SellerUpgradeRequested>(_onUpgradeRequested);
    on<SellerSubscribeRequested>(_onSubscribeRequested);
    on<SellerCancelSubscriptionRequested>(_onCancelSubscriptionRequested);
    on<SellerPlansLoadRequested>(_onPlansLoadRequested);
    on<SellerLogoUploadRequested>(_onLogoUploadRequested);
    on<SellerCoverUploadRequested>(_onCoverUploadRequested);
    on<SellerUpgradeFlowReset>(_onUpgradeFlowReset);
  }

  Future<void> _onProfileLoadRequested(
    SellerProfileLoadRequested event,
    Emitter<SellerState> emit,
  ) async {
    emit(state.copyWith(status: SellerStatus.loading, clearFailure: true));

    final result = await _repository.getSellerProfile();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load seller profile: ${failure.message}');
        emit(state.copyWith(
          status: SellerStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        emit(state.copyWith(
          status: SellerStatus.loaded,
          profile: profile,
          clearProfile: profile == null,
        ));
      },
    );
  }

  void _onBusinessTypeSelected(
    SellerBusinessTypeSelected event,
    Emitter<SellerState> emit,
  ) {
    emit(state.copyWith(
      selectedBusinessType: event.type,
      currentStep: 1,
    ));
  }

  void _onBusinessInfoUpdated(
    SellerBusinessInfoUpdated event,
    Emitter<SellerState> emit,
  ) {
    emit(state.copyWith(
      businessName: event.businessName,
      description: event.description,
      address: event.address,
      city: event.city,
      contactPhones: event.contactPhones ?? [],
      currentStep: 2,
    ));
  }

  void _onPlanSelected(
    SellerPlanSelected event,
    Emitter<SellerState> emit,
  ) {
    emit(state.copyWith(selectedPlan: event.plan));
  }

  Future<void> _onUpgradeRequested(
    SellerUpgradeRequested event,
    Emitter<SellerState> emit,
  ) async {
    if (!state.canCompleteUpgrade) {
      AppLogger.warning('Cannot complete upgrade: missing required fields');
      return;
    }

    emit(state.copyWith(status: SellerStatus.upgrading, clearFailure: true));

    final result = await _upgradeToSellerUseCase(
      UpgradeToSellerParams(
        businessName: state.businessName!,
        businessType: state.selectedBusinessType!,
        description: state.description,
        address: state.address,
        city: state.city,
        contactPhones: state.contactPhones.isNotEmpty ? state.contactPhones : null,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to upgrade to seller: ${failure.message}');
        emit(state.copyWith(
          status: SellerStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        AppLogger.info('Successfully upgraded to seller');
        emit(state.copyWith(
          status: SellerStatus.upgraded,
          profile: profile,
        ));
      },
    );
  }

  Future<void> _onSubscribeRequested(
    SellerSubscribeRequested event,
    Emitter<SellerState> emit,
  ) async {
    emit(state.copyWith(status: SellerStatus.loading, clearFailure: true));

    final result = await _repository.subscribeToPlan(event.plan);

    result.fold(
      (failure) {
        AppLogger.error('Failed to subscribe: ${failure.message}');
        emit(state.copyWith(
          status: SellerStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        AppLogger.info('Successfully subscribed to ${event.plan.name}');
        emit(state.copyWith(
          status: SellerStatus.loaded,
          profile: profile,
        ));
      },
    );
  }

  Future<void> _onCancelSubscriptionRequested(
    SellerCancelSubscriptionRequested event,
    Emitter<SellerState> emit,
  ) async {
    emit(state.copyWith(status: SellerStatus.loading, clearFailure: true));

    final result = await _repository.cancelSubscription();

    result.fold(
      (failure) {
        AppLogger.error('Failed to cancel subscription: ${failure.message}');
        emit(state.copyWith(
          status: SellerStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        AppLogger.info('Successfully cancelled subscription');
        emit(state.copyWith(
          status: SellerStatus.loaded,
          profile: profile,
        ));
      },
    );
  }

  Future<void> _onPlansLoadRequested(
    SellerPlansLoadRequested event,
    Emitter<SellerState> emit,
  ) async {
    final result = await _repository.getSubscriptionPlans();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load plans: ${failure.message}');
      },
      (plans) {
        emit(state.copyWith(plans: plans));
      },
    );
  }

  Future<void> _onLogoUploadRequested(
    SellerLogoUploadRequested event,
    Emitter<SellerState> emit,
  ) async {
    emit(state.copyWith(status: SellerStatus.loading, clearFailure: true));

    final uploadResult = await _repository.uploadLogo(event.filePath);

    await uploadResult.fold(
      (failure) async {
        AppLogger.error('Failed to upload logo: ${failure.message}');
        emit(state.copyWith(
          status: SellerStatus.error,
          failure: failure,
        ));
      },
      (logoUrl) async {
        final updateResult = await _repository.updateSellerProfile(
          logoUrl: logoUrl,
        );

        updateResult.fold(
          (failure) {
            emit(state.copyWith(
              status: SellerStatus.error,
              failure: failure,
            ));
          },
          (profile) {
            emit(state.copyWith(
              status: SellerStatus.loaded,
              profile: profile,
            ));
          },
        );
      },
    );
  }

  Future<void> _onCoverUploadRequested(
    SellerCoverUploadRequested event,
    Emitter<SellerState> emit,
  ) async {
    emit(state.copyWith(status: SellerStatus.loading, clearFailure: true));

    final uploadResult = await _repository.uploadCover(event.filePath);

    await uploadResult.fold(
      (failure) async {
        AppLogger.error('Failed to upload cover: ${failure.message}');
        emit(state.copyWith(
          status: SellerStatus.error,
          failure: failure,
        ));
      },
      (coverUrl) async {
        final updateResult = await _repository.updateSellerProfile(
          coverUrl: coverUrl,
        );

        updateResult.fold(
          (failure) {
            emit(state.copyWith(
              status: SellerStatus.error,
              failure: failure,
            ));
          },
          (profile) {
            emit(state.copyWith(
              status: SellerStatus.loaded,
              profile: profile,
            ));
          },
        );
      },
    );
  }

  void _onUpgradeFlowReset(
    SellerUpgradeFlowReset event,
    Emitter<SellerState> emit,
  ) {
    emit(state.resetUpgradeFlow());
  }
}
