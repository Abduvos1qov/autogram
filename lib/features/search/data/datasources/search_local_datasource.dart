import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/storage_service.dart';

/// Search local data source for caching recent searches

abstract class SearchLocalDataSource {
  Future<List<String>> getRecentSearches();
  Future<void> addRecentSearch(String query);
  Future<void> clearRecentSearches();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final StorageService storageService;
  static const int maxRecentSearches = 10;

  SearchLocalDataSourceImpl({required this.storageService});

  @override
  Future<List<String>> getRecentSearches() async {
    final searches = storageService.getStringList(StorageKeys.recentSearches);
    return searches ?? [];
  }

  @override
  Future<void> addRecentSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    final searches = await getRecentSearches();

    // Remove if already exists
    searches.remove(trimmedQuery);

    // Add to beginning
    searches.insert(0, trimmedQuery);

    // Keep only max recent searches
    final limitedSearches = searches.take(maxRecentSearches).toList();

    await storageService.setStringList(
      StorageKeys.recentSearches,
      limitedSearches,
    );
  }

  @override
  Future<void> clearRecentSearches() async {
    await storageService.remove(StorageKeys.recentSearches);
  }
}
