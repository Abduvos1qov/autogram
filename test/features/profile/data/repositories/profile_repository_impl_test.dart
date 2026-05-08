import 'dart:io';

import 'package:autogram/core/errors/exceptions.dart';
import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/profile/data/models/user_profile_model.dart';
import 'package:autogram/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/profile_fixtures.dart';
import '../../../../mocks/mocks.dart';

class _FakeFile extends Fake implements File {
  @override
  String get path => '/tmp/test.jpg';
}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemote;
  late MockNetworkInfo mockNetworkInfo;

  final tModel = UserProfileModel(
    id: ProfileFixtures.buyer.id,
    phone: ProfileFixtures.buyer.phone,
    email: ProfileFixtures.buyer.email,
    fullName: ProfileFixtures.buyer.fullName,
    avatarUrl: ProfileFixtures.buyer.avatarUrl,
    role: ProfileFixtures.buyer.role,
    isVerified: ProfileFixtures.buyer.isVerified,
    isActive: ProfileFixtures.buyer.isActive,
    language: ProfileFixtures.buyer.language,
    sellerProfileId: ProfileFixtures.buyer.sellerProfileId,
    createdAt: ProfileFixtures.buyer.createdAt,
    updatedAt: ProfileFixtures.buyer.updatedAt,
  );

  setUpAll(() {
    registerFallbackValue(_FakeFile());
  });

  setUp(() {
    mockRemote = MockProfileRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockRemote,
      networkInfo: mockNetworkInfo,
    );
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('getProfile', () {
    test('returns NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getProfile();

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(UserProfile) on success', () async {
      when(() => mockRemote.getProfile()).thenAnswer((_) async => tModel);

      final result = await repository.getProfile();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (p) => expect(p, tModel),
      );
    });

    test('returns Left(Failure) on ServerException', () async {
      when(() => mockRemote.getProfile())
          .thenThrow(const ServerException(message: 'server down'));

      final result = await repository.getProfile();

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateProfile', () {
    test('returns NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateProfile(fullName: 'X');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(UserProfile) on success', () async {
      when(() => mockRemote.updateProfile(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            language: any(named: 'language'),
          )).thenAnswer((_) async => tModel);

      final result = await repository.updateProfile(fullName: 'X');

      expect(result.isRight(), isTrue);
    });
  });

  group('updateAvatar', () {
    test('returns NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateAvatar(_FakeFile());

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(url) on success', () async {
      when(() => mockRemote.updateAvatar(any()))
          .thenAnswer((_) async => 'https://cdn/x.jpg');

      final result = await repository.updateAvatar(_FakeFile());

      expect(result, const Right('https://cdn/x.jpg'));
    });
  });

  group('deleteAccount', () {
    test('returns NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.deleteAccount();

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(void) on success', () async {
      when(() => mockRemote.deleteAccount()).thenAnswer((_) async {});

      final result = await repository.deleteAccount();

      expect(result.isRight(), isTrue);
    });
  });
}
