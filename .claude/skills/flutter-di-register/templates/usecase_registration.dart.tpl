// Add to imports at the top of `lib/di/injection.dart`, under the `// {{Feature}}`
// comment block:
import '../features/{{feature}}/domain/usecases/{{verb}}_{{feature}}_usecase.dart';

// Add inside `void _init{{Feature}}() { ... }` AFTER the repository registration
// and BEFORE the bloc registration. Group all use cases together; one line each.

  sl.registerLazySingleton(() => {{Verb}}{{Feature}}UseCase(sl()));
