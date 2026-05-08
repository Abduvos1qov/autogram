import 'dart:io';

import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/core/network/api_response.dart';
import 'package:autogram/core/usecases/usecase.dart';
import 'package:autogram/features/listing/domain/entities/listing.dart';
import 'package:autogram/features/listing/domain/usecases/get_seller_listings_usecase.dart';
import 'package:autogram/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:autogram/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:autogram/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:autogram/features/profile/presentation/bloc/profile_event.dart';
import 'package:autogram/features/profile/presentation/bloc/profile_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/profile_fixtures.dart';
import '../../../../mocks/mocks.dart';

class _FakeFile extends Fake implements File {
  @override
  String get path => '/tmp/avatar.jpg';
}

void main() {
  late ProfileBloc bloc;
  late MockGetProfileUseCase mockGetProfile;
  late MockUpdateProfileUseCase mockUpdateProfile;
  late MockUpdateAvatarUseCase mockUpdateAvatar;
  late MockDeleteAccountUseCase mockDeleteAccount;
  late MockGetSellerProfileUseCase mockGetSellerProfile;
  late MockGetSellerListingsUseCase mockGetSellerListings;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const UpdateProfileParams());
    registerFallbackValue(UpdateAvatarParams(_FakeFile()));
    registerFallbackValue(
      const GetSellerListingsParams(sellerId: 'seller-001'),
    );
  });

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
    mockUpdateProfile = MockUpdateProfileUseCase();
    mockUpdateAvatar = MockUpdateAvatarUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
    mockGetSellerProfile = MockGetSellerProfileUseCase();
    mockGetSellerListings = MockGetSellerListingsUseCase();

    bloc = ProfileBloc(
      getProfileUseCase: mockGetProfile,
      updateProfileUseCase: mockUpdateProfile,
      updateAvatarUseCase: mockUpdateAvatar,
      deleteAccountUseCase: mockDeleteAccount,
      getSellerProfileUseCase: mockGetSellerProfile,
      getSellerListingsUseCase: mockGetSellerListings,
    );
  });

  tearDown(() {
    bloc.close();
  });

  PaginatedResponse<Listing> page(List<Listing> items, {bool hasMore = false}) =>
      PaginatedResponse(
        data: items,
        page: 1,
        pageSize: 12,
        total: items.length,
        hasMore: hasMore,
      );

  test('initial state is ProfileState defaults', () {
    expect(bloc.state, const ProfileState());
    expect(bloc.state.status, ProfileStatus.initial);
    expect(bloc.state.profile, isNull);
    expect(bloc.state.sellerProfile, isNull);
    expect(bloc.state.activeListings, isEmpty);
    expect(bloc.state.currentTab, SellerStorefrontTab.active);
  });

  group('ProfileLoadRequested — buyer flow', () {
    blocTest<ProfileBloc, ProfileState>(
      'loads buyer profile and emits [loading, loaded] without seller data',
      build: () {
        when(() => mockGetProfile(any()))
            .thenAnswer((_) async => Right(ProfileFixtures.buyer));
        return bloc;
      },
      act: (b) => b.add(const ProfileLoadRequested()),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.profile, 'profile', ProfileFixtures.buyer)
            .having((s) => s.sellerProfile, 'sellerProfile', isNull)
            .having((s) => s.isSellerView, 'isSellerView', isFalse)
            .having((s) => s.activeListings, 'activeListings', isEmpty),
      ],
      verify: (_) {
        verify(() => mockGetProfile(any())).called(1);
        verifyNever(() => mockGetSellerProfile(any()));
        verifyNever(() => mockGetSellerListings(any()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits error when profile fetch fails',
      build: () {
        when(() => mockGetProfile(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'fail')),
        );
        return bloc;
      },
      act: (b) => b.add(const ProfileLoadRequested()),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.error)
            .having((s) => s.failure, 'failure',
                const ServerFailure(message: 'fail')),
      ],
    );
  });

  group('ProfileLoadRequested — seller flow', () {
    blocTest<ProfileBloc, ProfileState>(
      'loads seller profile + listings in parallel and emits [loading, loaded]',
      build: () {
        when(() => mockGetProfile(any()))
            .thenAnswer((_) async => Right(ProfileFixtures.sellerUser));
        when(() => mockGetSellerProfile(any())).thenAnswer(
          (_) async => Right(ProfileFixtures.sellerProfile),
        );
        when(() => mockGetSellerListings(
              any(that: isA<GetSellerListingsParams>().having(
                (p) => p.status,
                'status',
                ListingStatus.active,
              )),
            )).thenAnswer((_) async =>
            Right(page(ProfileFixtures.activeListings(3), hasMore: true)));
        when(() => mockGetSellerListings(
              any(that: isA<GetSellerListingsParams>().having(
                (p) => p.status,
                'status',
                ListingStatus.sold,
              )),
            )).thenAnswer(
          (_) async => Right(page(ProfileFixtures.soldListings(2))),
        );
        return bloc;
      },
      act: (b) => b.add(const ProfileLoadRequested()),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.loading),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.isSellerView, 'isSellerView', isTrue)
            .having((s) => s.profile, 'profile', ProfileFixtures.sellerUser)
            .having(
                (s) => s.sellerProfile, 'sellerProfile', ProfileFixtures.sellerProfile)
            .having((s) => s.activeListings.length, 'activeListings', 3)
            .having((s) => s.soldListings.length, 'soldListings', 2)
            .having((s) => s.activeHasMore, 'activeHasMore', isTrue)
            .having((s) => s.soldHasMore, 'soldHasMore', isFalse),
      ],
      verify: (_) {
        verify(() => mockGetSellerProfile(any())).called(1);
        verify(() => mockGetSellerListings(any())).called(2);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'falls back to buyer view when seller profile fetch fails',
      build: () {
        when(() => mockGetProfile(any()))
            .thenAnswer((_) async => Right(ProfileFixtures.sellerUser));
        when(() => mockGetSellerProfile(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'no row')),
        );
        when(() => mockGetSellerListings(any())).thenAnswer(
          (_) async => Right(page(const [])),
        );
        return bloc;
      },
      act: (b) => b.add(const ProfileLoadRequested()),
      verify: (b) {
        expect(b.state.profile, ProfileFixtures.sellerUser);
        expect(b.state.sellerProfile, isNull);
        expect(b.state.isSellerView, isFalse,
            reason: 'no SellerProfile = no storefront');
      },
    );
  });

  group('ProfileTabChanged', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits new state with the requested tab',
      build: () => bloc,
      seed: () => const ProfileState(currentTab: SellerStorefrontTab.active),
      act: (b) => b.add(const ProfileTabChanged(SellerStorefrontTab.sold)),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.currentTab, 'currentTab', SellerStorefrontTab.sold),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits nothing when tab is unchanged',
      build: () => bloc,
      seed: () => const ProfileState(currentTab: SellerStorefrontTab.about),
      act: (b) => b.add(const ProfileTabChanged(SellerStorefrontTab.about)),
      expect: () => const <ProfileState>[],
    );
  });

  group('ProfileLoadMoreListings', () {
    blocTest<ProfileBloc, ProfileState>(
      'loads next page of active listings and appends',
      build: () {
        when(() => mockGetSellerListings(any())).thenAnswer((invocation) async {
          return Right(page(ProfileFixtures.activeListings(2)));
        });
        return bloc;
      },
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.sellerUser,
        sellerProfile: ProfileFixtures.sellerProfile,
        activeListings: ProfileFixtures.activeListings(3),
        activePage: 1,
        activeHasMore: true,
        currentTab: SellerStorefrontTab.active,
      ),
      act: (b) => b.add(const ProfileLoadMoreListings()),
      verify: (b) {
        expect(b.state.activeListings.length, 5,
            reason: 'page 2 should append onto existing page 1');
        expect(b.state.activePage, 2);
        expect(b.state.isLoadingMoreActive, isFalse);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'no-op when there are no more pages',
      build: () => bloc,
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.sellerUser,
        sellerProfile: ProfileFixtures.sellerProfile,
        activeHasMore: false,
        currentTab: SellerStorefrontTab.active,
      ),
      act: (b) => b.add(const ProfileLoadMoreListings()),
      expect: () => const <ProfileState>[],
      verify: (_) {
        verifyNever(() => mockGetSellerListings(any()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'no-op on the about tab (no listings to paginate)',
      build: () => bloc,
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.sellerUser,
        sellerProfile: ProfileFixtures.sellerProfile,
        currentTab: SellerStorefrontTab.about,
      ),
      act: (b) => b.add(const ProfileLoadMoreListings()),
      expect: () => const <ProfileState>[],
    );
  });

  group('ProfileUpdateRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [updating, loaded] with the new profile on success',
      build: () {
        when(() => mockUpdateProfile(any())).thenAnswer(
          (_) async => Right(ProfileFixtures.buyer.copyWith(fullName: 'Y')),
        );
        return bloc;
      },
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.buyer,
      ),
      act: (b) => b.add(const ProfileUpdateRequested(fullName: 'Y')),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.updating),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.profile?.fullName, 'fullName', 'Y'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [updating, error] on failure',
      build: () {
        when(() => mockUpdateProfile(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'no')),
        );
        return bloc;
      },
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.buyer,
      ),
      act: (b) => b.add(const ProfileUpdateRequested(fullName: 'Y')),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.updating),
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.error),
      ],
    );
  });

  group('ProfileAvatarUpdateRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'patches the avatarUrl on the profile on success',
      build: () {
        when(() => mockUpdateAvatar(any()))
            .thenAnswer((_) async => const Right('https://cdn/new.jpg'));
        return bloc;
      },
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.buyer,
      ),
      act: (b) => b.add(ProfileAvatarUpdateRequested(_FakeFile())),
      verify: (b) {
        expect(b.state.profile?.avatarUrl, 'https://cdn/new.jpg');
        expect(b.state.status, ProfileStatus.loaded);
      },
    );
  });

  group('ProfileDeleteRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [updating, deleted] on success',
      build: () {
        when(() => mockDeleteAccount(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.buyer,
      ),
      act: (b) => b.add(const ProfileDeleteRequested()),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.updating),
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.deleted),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [updating, error] on failure',
      build: () {
        when(() => mockDeleteAccount(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'no')),
        );
        return bloc;
      },
      seed: () => ProfileState(
        status: ProfileStatus.loaded,
        profile: ProfileFixtures.buyer,
      ),
      act: (b) => b.add(const ProfileDeleteRequested()),
      expect: () => [
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.updating),
        isA<ProfileState>().having(
            (s) => s.status, 'status', ProfileStatus.error),
      ],
    );
  });
}
