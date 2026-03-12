import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/verify_forgot_password_otp_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late VerifyForgotPasswordOtpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyForgotPasswordOtpUseCase(mockRepository);
  });

  const tParams = VerifyForgotPasswordOtpParams(
    email: 'test@example.com',
    otp: '123456',
  );

  group('VerifyForgotPasswordOtpUseCase', () {
    test('should return void on successful verification', () async {
      when(() => mockRepository.verifyForgotPasswordOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(tParams);

      expect(result, const Right(null));
      verify(() => mockRepository.verifyForgotPasswordOtp(
            email: 'test@example.com',
            otp: '123456',
          )).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.verifyForgotPasswordOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          )).thenAnswer(
              (_) async => const Left(AuthFailure(message: 'Invalid OTP')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });
}
