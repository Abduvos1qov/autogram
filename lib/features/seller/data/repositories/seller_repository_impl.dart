import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/seller_repository.dart';
import '../datasources/seller_remote_datasource.dart';

/// Seller repository implementation

class SellerRepositoryImpl implements SellerRepository {
  final SellerRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SellerRepositoryImpl({
    required SellerRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, SellerProfile?>> getSellerProfile() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profile = await _remoteDataSource.getSellerProfile();
      return Right(profile);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerProfile>> createSellerProfile({
    required String businessName,
    required BusinessType businessType,
    String? description,
    String? address,
    String? city,
    List<String>? contactPhones,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profile = await _remoteDataSource.createSellerProfile(
        businessName: businessName,
        businessType: businessType,
        description: description,
        address: address,
        city: city,
        contactPhones: contactPhones,
      );
      return Right(profile);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerProfile>> updateSellerProfile({
    String? businessName,
    BusinessType? businessType,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? address,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    List<String>? contactPhones,
    String? telegram,
    String? instagram,
    String? website,
    Map<String, WorkingHours>? workingHours,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updates = <String, dynamic>{};

      if (businessName != null) updates['business_name'] = businessName;
      if (businessType != null) updates['business_type'] = businessType.name;
      if (description != null) updates['description'] = description;
      if (logoUrl != null) updates['logo_url'] = logoUrl;
      if (coverUrl != null) updates['cover_url'] = coverUrl;
      if (address != null) updates['address'] = address;
      if (city != null) updates['city'] = city;
      if (district != null) updates['district'] = district;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (contactPhones != null) updates['contact_phones'] = contactPhones;
      if (telegram != null) updates['telegram'] = telegram;
      if (instagram != null) updates['instagram'] = instagram;
      if (website != null) updates['website'] = website;
      if (workingHours != null) {
        updates['working_hours'] = workingHours.map((key, value) => MapEntry(
          key,
          {
            'open': value.open,
            'close': value.close,
            'is_closed': value.isClosed,
          },
        ));
      }

      final profile = await _remoteDataSource.updateSellerProfile(updates);
      return Right(profile);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlanDetails>>> getSubscriptionPlans() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final plans = await _remoteDataSource.getSubscriptionPlans();
      return Right(plans);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerProfile>> subscribeToPlan(SubscriptionPlan plan) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profile = await _remoteDataSource.subscribeToPlan(plan);
      return Right(profile);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerProfile>> cancelSubscription() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profile = await _remoteDataSource.cancelSubscription();
      return Right(profile);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadLogo(String filePath) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final url = await _remoteDataSource.uploadLogo(filePath);
      return Right(url);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCover(String filePath) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final url = await _remoteDataSource.uploadCover(filePath);
      return Right(url);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> canBecomeASeller() async {
    try {
      final canBecome = await _remoteDataSource.canBecomeASeller();
      return Right(canBecome);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
