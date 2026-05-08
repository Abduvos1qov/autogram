import 'dart:io';

import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

class _FakeFile extends Fake implements File {
  final String _path;
  _FakeFile(this._path);
  @override
  String get path => _path;
}

void main() {
  late UpdateAvatarUseCase usecase;
  late MockProfileRepository mockRepo;

  setUp(() {
    mockRepo = MockProfileRepository();
    usecase = UpdateAvatarUseCase(mockRepo);
  });

  setUpAll(() {
    registerFallbackValue(_FakeFile('/tmp/x.jpg'));
  });

  test('returns Right(url) when repository succeeds', () async {
    when(() => mockRepo.updateAvatar(any()))
        .thenAnswer((_) async => const Right('https://cdn/x.jpg'));

    final result =
        await usecase(UpdateAvatarParams(_FakeFile('/tmp/avatar.jpg')));

    expect(result, const Right('https://cdn/x.jpg'));
    verify(() => mockRepo.updateAvatar(any())).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => mockRepo.updateAvatar(any())).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'upload failed')),
    );

    final result =
        await usecase(UpdateAvatarParams(_FakeFile('/tmp/avatar.jpg')));

    expect(result, const Left(ServerFailure(message: 'upload failed')));
  });

  test('UpdateAvatarParams equality is based on file path', () {
    final a = UpdateAvatarParams(_FakeFile('/tmp/a.jpg'));
    final b = UpdateAvatarParams(_FakeFile('/tmp/a.jpg'));
    final c = UpdateAvatarParams(_FakeFile('/tmp/b.jpg'));
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });
}
