// Add to imports at the top of `lib/di/injection.dart`, under the `// {{Feature}}`
// comment block (create the block if this is a brand-new feature):
import '../features/{{feature}}/data/datasources/{{feature}}_remote_datasource.dart';
// If you also have a local datasource:
import '../features/{{feature}}/data/datasources/{{feature}}_local_datasource.dart';

// Add inside `void _init{{Feature}}() { ... }` BEFORE the repository registration.
// Convention: one blank line above, one blank line below.

  sl.registerLazySingleton<{{Feature}}RemoteDataSource>(
    () => {{Feature}}RemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Optional — only if the feature caches locally:
  sl.registerLazySingleton<{{Feature}}LocalDataSource>(
    () => {{Feature}}LocalDataSourceImpl(
      storageService: sl(),
      secureStorageService: sl(),
    ),
  );
