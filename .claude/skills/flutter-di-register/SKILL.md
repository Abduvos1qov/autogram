---
name: flutter-di-register
description: Register a new datasource, repository, use case, or BLoC in the Autogram `lib/di/injection.dart` per-feature DI module. Use when the user says "DI ga qo'sh", "register X in DI", "module qo'sh", "X ni DI ga ulang", or after flutter-code-writer creates a new datasource / repository / use case / bloc that hasn't been wired up yet. Inserts a `registerLazySingleton` or `registerFactory` line into the matching `_init<Feature>()` function and adds the necessary imports at the top of `injection.dart`.
---

# flutter-di-register

Wires a new datasource / repository / use case / bloc into the appropriate per-feature `_init<Feature>()` block of `lib/di/injection.dart`.

## When to use

Trigger this skill when:
- User says "DI ga qo'sh", "register X in DI", "module qo'sh", "X ni DI ga ulang"
- After `flutter-code-writer` writes a new `*RemoteDataSource`, `*LocalDataSource`, `*Repository` / `*RepositoryImpl`, `*UseCase`, or `*Bloc`
- Before adding a screen that depends on a Bloc that isn't yet registered

Do **not** use this skill for:
- The initial bootstrap of the project's DI graph (one-time setup, already done in `lib/di/injection.dart`)
- Registering anything in a hypothetical "scope" — Autogram uses a single global GetIt instance (`sl`), no per-feature scopes

## DI architecture (Autogram convention)

The whole DI graph lives in **one file** — `lib/di/injection.dart`. Pattern:

```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Externals
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Per-feature
  await _initCore();
  _initAuth();
  _initHome();
  _initReels();
  _initSearch();
  // ... one _init<Feature>() per feature module
}
```

Each `_init<Feature>()` function registers everything that feature owns: datasources → repository → use cases → bloc.

```dart
void _initAuth() {
  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      storageService: sl(),
      secureStorageService: sl(),
    ),
  );

  // Repository (abstract type as key)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases (concrete type — no abstract use case in this project)
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  // ...

  // Bloc — Factory (fresh instance per page)
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      getCurrentUserUseCase: sl(),
      // ...
    ),
  );
}
```

### Convention by layer

| Layer | Pattern | Lifecycle |
|---|---|---|
| Datasource | `registerLazySingleton<<X>RemoteDataSource>(() => <X>RemoteDataSourceImpl(...))` | Lazy singleton (abstract type as key) |
| Repository | `registerLazySingleton<<X>Repository>(() => <X>RepositoryImpl(...))` | Lazy singleton (abstract type as key) |
| Use case | `registerLazySingleton(() => <Verb><X>UseCase(sl()))` | Lazy singleton (concrete type — no abstract base) |
| Bloc | `registerFactory(() => <X>Bloc(<dep>UseCase: sl(), ...))` | Factory (fresh per page) |

**Why lazy singleton for use cases (not factory):** they are stateless and cheap to construct, and reusing the same instance avoids reallocation. The Bloc gets a fresh instance, the use case it calls is shared.

**Why factory for Blocs:** Blocs are short-lived (per screen). A factory ensures each page gets a fresh state.

## Steps

1. **Identify** the layer the user wants to register (datasource / repository / use case / bloc) and the feature.
2. **Locate** `lib/di/injection.dart` and find the matching `_init<Feature>()` function. If the function doesn't exist (new feature), create it and add a call to it from `initDependencies()`.
3. **Read** the existing function to understand the registration order and naming conventions used.
4. **Insert** the new registration line in the right section (datasources, then repository, then use cases, then bloc — in that order). Use the right template:
   - `templates/datasource_registration.dart.tpl`
   - `templates/repository_registration.dart.tpl`
   - `templates/usecase_registration.dart.tpl`
   - `templates/bloc_registration.dart.tpl`
5. **Add imports** at the top of `injection.dart` under the matching `// <Feature>` comment block. Order: domain interfaces → data implementations (matches the existing convention).
6. **Verify**: ask the user to run `flutter analyze` (or run via Bash if permitted). Look for "couldn't be resolved" errors — usually means a missing import or a wrong type reference.
7. **Hint** about wiring downstream:
   - For a new use case → mention that the Bloc constructor needs to be updated to accept it.
   - For a new Bloc → mention that the screen wraps it with `BlocProvider(create: (_) => sl<<Feature>Bloc>())`.

## Reference patterns

### Datasource registration

```dart
sl.registerLazySingleton<FavoritesRemoteDataSource>(
  () => FavoritesRemoteDataSourceImpl(supabaseClient: sl()),
);

sl.registerLazySingleton<FavoritesLocalDataSource>(
  () => FavoritesLocalDataSourceImpl(
    storageService: sl(),
    secureStorageService: sl(),
  ),
);
```

- Always against the **abstract** type as the key.
- Common dependencies sourced from `_initCore()`: `SupabaseClient`, `StorageService`, `SecureStorageService`, `NetworkInfo`, `ApiClient`, `Dio`.

### Repository registration

```dart
sl.registerLazySingleton<FavoritesRepository>(
  () => FavoritesRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ),
);
```

- Always abstract type as the key.
- Constructor uses named `required` parameters in the impl.

### Use case registration

```dart
sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
sl.registerLazySingleton(() => ClearFavoritesUseCase(sl()));
```

- Concrete type (no abstract base for use cases in this project).
- Single positional dependency: the repository.
- One blank line between sections is fine; one line per use case.

### Bloc registration

```dart
sl.registerFactory(
  () => FavoritesBloc(
    getFavoritesUseCase: sl(),
    toggleFavoriteUseCase: sl(),
    clearFavoritesUseCase: sl(),
  ),
);
```

- `registerFactory` (NOT `registerLazySingleton`) — fresh instance per page.
- Named `required` parameters mapped to `sl()` calls.

## Conventions (mandatory)

1. **Single global `sl = GetIt.instance`** — no per-feature scopes, no `pushNewScope`. The entire app shares one container.
2. **No `injectable` annotations** — manual registration only. The `injectable_generator` package is in `dev_dependencies` but unused. Do not introduce `@injectable` / `@module` without explicit user approval.
3. **`sl()` for resolution** — the global getter. Type inference from the registration is enough; rarely need explicit `sl<X>()` inside a constructor.
4. **Repository registers the interface, not the impl** — `registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(...))`. This way callers depend on the abstraction.
5. **Datasource registers the interface when there is one** — most datasources have an abstract pair (`AuthRemoteDataSource` + `AuthRemoteDataSourceImpl`).
6. **Use case registers the concrete class** — no abstract base for use cases (the `UseCase<Type, Params>` interface in `lib/core/usecases/usecase.dart` is the contract; concrete classes implement it).
7. **Bloc → `registerFactory`** — short-lived per page.
8. **Imports grouped by feature** — the file uses `// <Feature>` comment headers; add new imports under the matching block. Within a block, alphabetize by file path.
9. **Order inside `_init<Feature>()`** — datasources → repository → use cases → bloc. Easier to read, matches the layer dependency direction.
10. **Call from `initDependencies()`** — every new `_init<Feature>()` function must be called from `initDependencies()`. The function does nothing unless invoked.

## Anti-patterns (reject if user asks)

- Adding `@injectable` / `@module` annotations — codegen DI is not used. Approval needed for the first introduction.
- Registering a Bloc as `registerLazySingleton` — Blocs must be factories so each page gets a fresh state.
- Using `registerFactory` for a use case or repository — they are stateless singletons; factories add unnecessary construction cost.
- Per-feature `GetIt` scopes (`pushNewScope` / `popScope`) — Autogram uses a single global container.
- Cross-feature DI lookup that creates implicit dependencies — if `_initFavorites()` resolves something only registered in `_initSeller()`, the load order matters and is fragile. Prefer making such dependencies explicit (move shared dep to `_initCore()` or a separate `_initShared()` block).
- Calling `sl<X>()` inside a screen body — use `BlocProvider(create: (_) => sl<XBloc>())` to source the bloc, not direct lookups.
