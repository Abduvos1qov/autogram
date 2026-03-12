import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late VerifyOtpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepository);
  });

  const tParams = VerifyOtpParams(email: 'test@example.com', otp: '123456');

  group('VerifyOtpUseCase', () {
    test('should return User on successful OTP verification', () async {
      when(() => mockRepository.verifyOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => Right(UserFixtures.buyer));

      final result = await useCase(tParams);

      expect(result, Right(UserFixtures.buyer));
      verify(() => mockRepository.verifyOtp(
            email: 'test@example.com',
            otp: '123456',
          )).called(1);
    });

    test('should return Failure on invalid OTP', () async {
      when(() => mockRepository.verifyOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          )).thenAnswer(
              (_) async => const Left(AuthFailure(message: 'Invalid OTP')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });
}
