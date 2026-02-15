import 'package:mocktail/mocktail.dart';

import 'package:autogram/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/complete_profile_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/logout_usecase.dart';
import 'package:autogram/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:autogram/features/search/domain/usecases/search_listings_usecase.dart';
import 'package:autogram/features/search/domain/usecases/get_brands_usecase.dart';
import 'package:autogram/features/listing/domain/usecases/get_listing_usecase.dart';
import 'package:autogram/features/listing/domain/usecases/get_seller_usecase.dart';

/// Mock Auth Use Cases
class MockSendOtpUseCase extends Mock implements SendOtpUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockCompleteProfileUseCase extends Mock implements CompleteProfileUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

/// Mock Home Use Cases
class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

/// Mock Search Use Cases
class MockSearchListingsUseCase extends Mock implements SearchListingsUseCase {}

class MockGetBrandsUseCase extends Mock implements GetBrandsUseCase {}

/// Mock Listing Use Cases
class MockGetListingUseCase extends Mock implements GetListingUseCase {}

class MockGetSellerUseCase extends Mock implements GetSellerUseCase {}
