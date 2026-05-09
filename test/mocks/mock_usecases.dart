import 'package:mocktail/mocktail.dart';

import 'package:autogram/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/set_username_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/check_username_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/logout_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/verify_forgot_password_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/reset_password_with_new_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/resend_signup_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/send_forgot_password_otp_usecase.dart';
import 'package:autogram/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:autogram/features/search/domain/usecases/search_listings_usecase.dart';
import 'package:autogram/features/search/domain/usecases/get_brands_usecase.dart';
import 'package:autogram/features/listing/domain/usecases/get_listing_usecase.dart';
import 'package:autogram/features/listing/domain/usecases/get_seller_usecase.dart';
import 'package:autogram/features/listing/domain/usecases/get_seller_listings_usecase.dart';
import 'package:autogram/features/reels/domain/usecases/get_seller_reels_usecase.dart';
import 'package:autogram/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:autogram/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:autogram/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:autogram/features/profile/domain/usecases/delete_account_usecase.dart';
import 'package:autogram/features/seller/domain/usecases/get_seller_profile_usecase.dart';

/// Mock Auth Use Cases
class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockSetUsernameUseCase extends Mock implements SetUsernameUseCase {}

class MockCheckUsernameUseCase extends Mock implements CheckUsernameUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockVerifyForgotPasswordOtpUseCase extends Mock
    implements VerifyForgotPasswordOtpUseCase {}

class MockResetPasswordWithNewUseCase extends Mock
    implements ResetPasswordWithNewUseCase {}

class MockResendSignUpOtpUseCase extends Mock
    implements ResendSignUpOtpUseCase {}

class MockSendForgotPasswordOtpUseCase extends Mock
    implements SendForgotPasswordOtpUseCase {}

/// Mock Home Use Cases
class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

/// Mock Search Use Cases
class MockSearchListingsUseCase extends Mock implements SearchListingsUseCase {}

class MockGetBrandsUseCase extends Mock implements GetBrandsUseCase {}

/// Mock Listing Use Cases
class MockGetListingUseCase extends Mock implements GetListingUseCase {}

class MockGetSellerUseCase extends Mock implements GetSellerUseCase {}

class MockGetSellerListingsUseCase extends Mock
    implements GetSellerListingsUseCase {}

/// Mock Profile Use Cases
class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockUpdateAvatarUseCase extends Mock implements UpdateAvatarUseCase {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

/// Mock Seller Use Cases
class MockGetSellerProfileUseCase extends Mock
    implements GetSellerProfileUseCase {}

/// Mock Reels Use Cases
class MockGetSellerReelsUseCase extends Mock
    implements GetSellerReelsUseCase {}
