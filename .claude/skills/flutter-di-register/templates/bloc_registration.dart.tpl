// Add to imports at the top of `lib/di/injection.dart`, under the `// {{Feature}}`
// comment block:
import '../features/{{feature}}/presentation/bloc/{{feature}}_bloc.dart';

// Add inside `void _init{{Feature}}() { ... }` AS THE LAST registration in the function.
// Use registerFactory (NOT registerLazySingleton) — Blocs are short-lived per page.

  sl.registerFactory(
    () => {{Feature}}Bloc(
      // List every required use case dependency from the Bloc constructor:
      // <verb><feature>UseCase: sl(),
      // ...
    ),
  );
