import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_profile.dart';
import '../repositories/seller_repository.dart';

/// Upgrade to seller use case

class UpgradeToSellerUseCase implements UseCase<SellerProfile, UpgradeToSellerParams> {
  final SellerRepository _repository;

  UpgradeToSellerUseCase(this._repository);

  @override
  Future<Either<Failure, SellerProfile>> call(UpgradeToSellerParams params) {
    return _repository.createSellerProfile(
      businessName: params.businessName,
      businessType: params.businessType,
      description: params.description,
      address: params.address,
      city: params.city,
      contactPhones: params.contactPhones,
    );
  }
}

class UpgradeToSellerParams extends Equatable {
  final String businessName;
  final BusinessType businessType;
  final String? description;
  final String? address;
  final String? city;
  final List<String>? contactPhones;

  const UpgradeToSellerParams({
    required this.businessName,
    required this.businessType,
    this.description,
    this.address,
    this.city,
    this.contactPhones,
  });

  @override
  List<Object?> get props => [
        businessName,
        businessType,
        description,
        address,
        city,
        contactPhones,
      ];
}
