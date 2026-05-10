import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/contact_phone.dart';
import '../entities/seller_profile.dart';
import '../repositories/seller_repository.dart';

/// Params for [UpdateSellerProfileUseCase].
///
/// All fields are nullable on purpose — only the non-null ones are forwarded
/// to the backend. Sentinel `''` (empty string) is used to **clear** a value
/// (e.g. user empties their Instagram handle); the data layer translates that
/// to `null` upstream where appropriate.
class UpdateSellerProfileParams extends Equatable {
  final String? username;
  final String? businessName;
  final BusinessType? businessType;
  final String? description;
  final String? address;
  final String? city;
  final String? district;
  final List<ContactPhone>? contactPhones;
  final String? contactPersonName;
  final String? contactPersonRole;
  final String? telegram;
  final String? instagram;
  final String? facebook;
  final String? youtube;
  final String? website;
  final Map<String, WorkingHours>? workingHours;

  const UpdateSellerProfileParams({
    this.username,
    this.businessName,
    this.businessType,
    this.description,
    this.address,
    this.city,
    this.district,
    this.contactPhones,
    this.contactPersonName,
    this.contactPersonRole,
    this.telegram,
    this.instagram,
    this.facebook,
    this.youtube,
    this.website,
    this.workingHours,
  });

  @override
  List<Object?> get props => [
        username,
        businessName,
        businessType,
        description,
        address,
        city,
        district,
        contactPhones,
        contactPersonName,
        contactPersonRole,
        telegram,
        instagram,
        facebook,
        youtube,
        website,
        workingHours,
      ];
}

class UpdateSellerProfileUseCase
    implements UseCase<SellerProfile, UpdateSellerProfileParams> {
  final SellerRepository _repository;

  UpdateSellerProfileUseCase(this._repository);

  @override
  Future<Either<Failure, SellerProfile>> call(
    UpdateSellerProfileParams params,
  ) {
    return _repository.updateSellerProfile(
      username: params.username,
      businessName: params.businessName,
      businessType: params.businessType,
      description: params.description,
      address: params.address,
      city: params.city,
      district: params.district,
      contactPhones: params.contactPhones,
      contactPersonName: params.contactPersonName,
      contactPersonRole: params.contactPersonRole,
      telegram: params.telegram,
      instagram: params.instagram,
      facebook: params.facebook,
      youtube: params.youtube,
      website: params.website,
      workingHours: params.workingHours,
    );
  }
}
