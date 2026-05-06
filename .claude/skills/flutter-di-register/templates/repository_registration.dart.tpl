// Add to imports at the top of `lib/di/injection.dart`, under the `// {{Feature}}`
// comment block. Order: domain interface first, then data implementation.
import '../features/{{feature}}/data/repositories/{{feature}}_repository_impl.dart';
import '../features/{{feature}}/domain/repositories/{{feature}}_repository.dart';

// Add inside `void _init{{Feature}}() { ... }` AFTER the datasource registrations
// and BEFORE the use case registrations. One blank line above, one blank line below.

  sl.registerLazySingleton<{{Feature}}Repository>(
    () => {{Feature}}RepositoryImpl(
      remoteDataSource: sl(),
      // Add other dependencies as needed:
      // localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
