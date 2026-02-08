import 'package:mocktail/mocktail.dart';

import 'package:autogram/features/auth/domain/repositories/auth_repository.dart';
import 'package:autogram/features/home/domain/repositories/home_repository.dart';
import 'package:autogram/features/search/domain/repositories/search_repository.dart';
import 'package:autogram/features/chat/domain/repositories/chat_repository.dart';
import 'package:autogram/features/saved/domain/repositories/saved_repository.dart';
import 'package:autogram/features/listing/domain/repositories/listing_repository.dart';
import 'package:autogram/features/profile/domain/repositories/profile_repository.dart';
import 'package:autogram/features/notifications/domain/repositories/notification_repository.dart';
import 'package:autogram/core/network/network_info.dart';

/// Mock Auth Repository
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock Home Repository
class MockHomeRepository extends Mock implements HomeRepository {}

/// Mock Search Repository
class MockSearchRepository extends Mock implements SearchRepository {}

/// Mock Chat Repository
class MockChatRepository extends Mock implements ChatRepository {}

/// Mock Saved Repository
class MockSavedRepository extends Mock implements SavedRepository {}

/// Mock Listing Repository
class MockListingRepository extends Mock implements ListingRepository {}

/// Mock Profile Repository
class MockProfileRepository extends Mock implements ProfileRepository {}

/// Mock Notification Repository
class MockNotificationRepository extends Mock implements NotificationRepository {}

/// Mock Network Info
class MockNetworkInfo extends Mock implements NetworkInfo {}
