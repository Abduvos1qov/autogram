import 'package:mocktail/mocktail.dart';

import 'package:autogram/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:autogram/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:autogram/features/home/data/datasources/home_remote_datasource.dart';
import 'package:autogram/features/search/data/datasources/search_remote_datasource.dart';
import 'package:autogram/features/search/data/datasources/search_local_datasource.dart';
import 'package:autogram/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:autogram/features/saved/data/datasources/saved_remote_datasource.dart';
import 'package:autogram/features/listing/data/datasources/listing_remote_datasource.dart';

/// Mock Auth Data Sources
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

/// Mock Home Data Sources
class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

/// Mock Search Data Sources
class MockSearchRemoteDataSource extends Mock implements SearchRemoteDataSource {}

class MockSearchLocalDataSource extends Mock implements SearchLocalDataSource {}

/// Mock Chat Data Sources
class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

/// Mock Saved Data Sources
class MockSavedRemoteDataSource extends Mock implements SavedRemoteDataSource {}

/// Mock Listing Data Sources
class MockListingRemoteDataSource extends Mock implements ListingRemoteDataSource {}
