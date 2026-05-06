import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/storage_service.dart';

// Auth
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/sign_up_usecase.dart';
import '../features/auth/domain/usecases/reset_password_usecase.dart';
import '../features/auth/domain/usecases/set_username_usecase.dart';
import '../features/auth/domain/usecases/check_username_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../features/auth/domain/usecases/verify_forgot_password_otp_usecase.dart';
import '../features/auth/domain/usecases/reset_password_with_new_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// Home
import '../features/home/data/datasources/home_remote_datasource.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/get_feed_usecase.dart';
import '../features/home/presentation/bloc/home_bloc.dart';

// Reels
import '../features/reels/data/datasources/reels_remote_datasource.dart';
import '../features/reels/data/repositories/reels_repository_impl.dart';
import '../features/reels/domain/repositories/reels_repository.dart';
import '../features/reels/domain/usecases/get_reels_usecase.dart';
import '../features/reels/domain/usecases/like_reel_usecase.dart';
import '../features/reels/domain/usecases/save_reel_usecase.dart';
import '../features/reels/presentation/bloc/reels_bloc.dart';

// Search
import '../features/search/data/datasources/search_local_datasource.dart';
import '../features/search/data/datasources/search_remote_datasource.dart';
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/domain/usecases/get_brands_usecase.dart';
import '../features/search/domain/usecases/search_listings_usecase.dart';
import '../features/search/presentation/bloc/search_bloc.dart';

// Listing
import '../features/listing/data/datasources/listing_remote_datasource.dart';
import '../features/listing/data/repositories/listing_repository_impl.dart';
import '../features/listing/domain/repositories/listing_repository.dart';
import '../features/listing/domain/usecases/get_listing_usecase.dart';
import '../features/listing/presentation/bloc/listing_bloc.dart';

// Saved
import '../features/saved/data/datasources/saved_remote_datasource.dart';
import '../features/saved/data/repositories/saved_repository_impl.dart';
import '../features/saved/domain/repositories/saved_repository.dart';
import '../features/saved/presentation/bloc/saved_bloc.dart';

// Chat
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/presentation/bloc/conversations_bloc.dart';

// Seller
import '../features/seller/data/datasources/seller_remote_datasource.dart';
import '../features/seller/data/repositories/seller_repository_impl.dart';
import '../features/seller/domain/repositories/seller_repository.dart';
import '../features/seller/domain/usecases/upgrade_to_seller_usecase.dart';
import '../features/seller/presentation/bloc/seller_bloc.dart';

// Seller Members
import '../features/seller/data/datasources/seller_member_remote_datasource.dart';
import '../features/seller/data/repositories/seller_member_repository_impl.dart';
import '../features/seller/domain/repositories/seller_member_repository.dart';
import '../features/seller/domain/usecases/get_team_members_usecase.dart';
import '../features/seller/domain/usecases/add_member_usecase.dart';
import '../features/seller/domain/usecases/update_member_role_usecase.dart';
import '../features/seller/domain/usecases/remove_member_usecase.dart';
import '../features/seller/domain/usecases/get_current_membership_usecase.dart';

// Seller Invitations
import '../features/seller/data/datasources/seller_invitation_remote_datasource.dart';
import '../features/seller/data/repositories/seller_invitation_repository_impl.dart';
import '../features/seller/domain/repositories/seller_invitation_repository.dart';
import '../features/seller/domain/usecases/send_invitation_usecase.dart';
import '../features/seller/domain/usecases/get_pending_invitations_usecase.dart';
import '../features/seller/domain/usecases/accept_invitation_usecase.dart';
import '../features/seller/domain/usecases/reject_invitation_usecase.dart';
import '../features/seller/domain/usecases/cancel_invitation_usecase.dart';
import '../features/seller/domain/usecases/get_my_invitations_usecase.dart';

// Team BLoC
import '../features/seller/presentation/bloc/team/team_bloc.dart';

// Activity Log
import '../features/seller/data/datasources/activity_log_remote_datasource.dart';
import '../features/seller/data/repositories/activity_log_repository_impl.dart';
import '../features/seller/domain/repositories/activity_log_repository.dart';
import '../features/seller/domain/usecases/log_activity_usecase.dart';
import '../features/seller/domain/usecases/get_activity_logs_usecase.dart';
import '../features/seller/domain/usecases/get_member_activity_logs_usecase.dart';

// Permission Service
import '../core/services/permission_service.dart';

// Notifications
import '../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';

// Profile
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/delete_account_usecase.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/domain/usecases/update_avatar_usecase.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Core
  await _initCore();

  // Features
  _initAuth();
  _initHome();
  _initReels();
  _initSearch();
  _initListing();
  _initSaved();
  _initChat();
  _initSeller();
  _initSellerMembers();
  _initSellerInvitations();
  _initActivityLog();
  _initTeam();
  _initProfile();
  _initNotifications();
}

Future<void> _initCore() async {
  // Services
  final storageService = StorageService();
  await storageService.init();
  sl.registerLazySingleton<StorageService>(() => storageService);

  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(supabase: sl(),
      ));
  sl.registerLazySingleton<PermissionService>(() => PermissionService());
}

void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      storageService: sl(),
      secureStorageService: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SetUsernameUseCase(sl()));
  sl.registerLazySingleton(() => CheckUsernameUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyForgotPasswordOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordWithNewUseCase(sl()));

  // BLoC
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        resetPasswordUseCase: sl(),
        setUsernameUseCase: sl(),
        checkUsernameUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        verifyOtpUseCase: sl(),
        verifyForgotPasswordOtpUseCase: sl(),
        resetPasswordWithNewUseCase: sl(),
        authRepository: sl(),
      ));
}

void _initHome() {
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFeedUseCase(sl()));

  // BLoC
  sl.registerFactory(() => HomeBloc(
        getFeedUseCase: sl(),
        repository: sl(),
      ));
}

void _initReels() {
  // Data sources
  sl.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetReelsUseCase(sl()));
  sl.registerLazySingleton(() => LikeReelUseCase(sl()));
  sl.registerLazySingleton(() => SaveReelUseCase(sl()));

  // BLoC
  sl.registerFactory(() => ReelsBloc(
        getReelsUseCase: sl(),
        likeReelUseCase: sl(),
        saveReelUseCase: sl(),
        repository: sl(),
      ));
}

void _initSearch() {
  // Data sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(storageService: sl()),
  );

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchListingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBrandsUseCase(sl()));

  // BLoC
  sl.registerFactory(() => SearchBloc(
        searchListingsUseCase: sl(),
        getBrandsUseCase: sl(),
        repository: sl(),
      ));
}

void _initListing() {
  // Data sources
  sl.registerLazySingleton<ListingRemoteDataSource>(
    () => ListingRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetListingUseCase(sl()));

  // BLoC
  sl.registerFactory(() => ListingBloc(
        getListingUseCase: sl(),
        repository: sl(),
      ));
}

void _initSaved() {
  // Data sources
  sl.registerLazySingleton<SavedRemoteDataSource>(
    () => SavedRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<SavedRepository>(
    () => SavedRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(() => SavedBloc(repository: sl()));
}

void _initChat() {
  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(() => ConversationsBloc(repository: sl()));
}

void _initSeller() {
  // Data sources
  sl.registerLazySingleton<SellerRemoteDataSource>(
    () => SellerRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<SellerRepository>(
    () => SellerRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UpgradeToSellerUseCase(sl()));

  // BLoC
  sl.registerFactory(() => SellerBloc(
        repository: sl(),
        upgradeToSellerUseCase: sl(),
      ));
}

void _initSellerMembers() {
  // Data sources
  sl.registerLazySingleton<SellerMemberRemoteDataSource>(
    () => SellerMemberRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<SellerMemberRepository>(
    () => SellerMemberRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTeamMembersUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMemberRoleUseCase(sl()));
  sl.registerLazySingleton(() => RemoveMemberUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentMembershipUseCase(sl()));
}

void _initSellerInvitations() {
  // Data sources
  sl.registerLazySingleton<SellerInvitationRemoteDataSource>(
    () => SellerInvitationRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<SellerInvitationRepository>(
    () => SellerInvitationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendInvitationUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingInvitationsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptInvitationUseCase(sl()));
  sl.registerLazySingleton(() => RejectInvitationUseCase(sl()));
  sl.registerLazySingleton(() => CancelInvitationUseCase(sl()));
  sl.registerLazySingleton(() => GetMyInvitationsUseCase(sl()));
}

void _initActivityLog() {
  // Data sources
  sl.registerLazySingleton<ActivityLogRemoteDataSource>(
    () => ActivityLogRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ActivityLogRepository>(
    () => ActivityLogRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LogActivityUseCase(sl()));
  sl.registerLazySingleton(() => GetActivityLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetMemberActivityLogsUseCase(sl()));
}

void _initTeam() {
  // BLoC
  sl.registerFactory(() => TeamBloc(
        getTeamMembersUseCase: sl(),
        updateMemberRoleUseCase: sl(),
        removeMemberUseCase: sl(),
        getCurrentMembershipUseCase: sl(),
        sendInvitationUseCase: sl(),
        getPendingInvitationsUseCase: sl(),
        acceptInvitationUseCase: sl(),
        rejectInvitationUseCase: sl(),
        cancelInvitationUseCase: sl(),
        getMyInvitationsUseCase: sl(),
        logActivityUseCase: sl(),
      ));
}

void _initProfile() {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // BLoC
  sl.registerFactory(() => ProfileBloc(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        updateAvatarUseCase: sl(),
        deleteAccountUseCase: sl(),
      ));
}

void _initNotifications() {
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(() => NotificationsBloc(repository: sl()));
}
