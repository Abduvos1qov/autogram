---
name: flutter-bloc-scaffold
description: Scaffold a BLoC/Event/State triplet for a new feature in the Autogram Flutter project. Use when the user asks to "create a BLoC", "scaffold bloc for X", "BLoC yoz", "yangi feature uchun bloc qo'sh", or when flutter-feature-planner outputs a "BLoC scaffold" task. Generates 3 separate files using the project's exact pattern (Equatable event hierarchy, Equatable state class hierarchy with multiple subclasses, constructor injection of use cases, `Either.fold` async work) — modeled on `lib/features/auth/presentation/bloc/auth_bloc.dart`.
---

# flutter-bloc-scaffold

Generates the standard 3-file BLoC triplet for a new feature in the Autogram Flutter project.

## When to use

Trigger this skill when:
- User says "BLoC yoz", "create a BLoC for X", "scaffold bloc for X", "yangi feature uchun bloc qo'sh"
- A feature spec from `flutter-feature-planner` lists a "BLoC scaffold" task
- `flutter-code-writer` is about to write a feature's state-management layer

Do **not** use this skill for:
- UI screens / widgets (use `flutter-ui-builder` agent)
- Repositories or datasources (use `flutter-code-writer` agent)
- Tests (use `flutter-test-writer` agent)

## Inputs to gather

Before generating, confirm with the user:

1. **Feature name** in `snake_case` (e.g., `forgot_password`, `cart_checkout`, `favorites`)
2. **Use case dependencies** — full type names of the `UseCase`s the Bloc will call. List each one. Example: `SignInUseCase`, `GetCurrentUserUseCase`, `LogoutUseCase`. If the Bloc has no business-logic dependencies (rare — usually a pure UI bloc like a tab selector), say so.
3. **Initial events** — list of event class names in `<Feature><Verb>Requested` form. If the user gives only verbs ("submit, change input, clear error"), translate to `<Feature>SubmitRequested`, `<Feature>InputChanged`, `<Feature>ErrorCleared`.
4. **State subclasses** — at minimum: `<Feature>Initial`, `<Feature>Loading`, `<Feature>Loaded` (with payload), `<Feature>Error`. Ask about feature-specific subclasses (e.g., `AuthNeedsUsername`, `SearchEmpty`, `OrderSubmitting`).

## Output structure

Three independent files (no `part` / `part of`) at:

```
lib/features/<name>/presentation/bloc/
├── <name>_bloc.dart      # Bloc class + handlers; imports event + state files
├── <name>_event.dart     # Equatable event hierarchy
└── <name>_state.dart     # Equatable state class hierarchy (multiple subclasses)
```

Use `templates/bloc.dart.tpl`, `templates/event.dart.tpl`, `templates/state.dart.tpl` as starting points. See `reference/auth_bloc_example.md` for the canonical fully-fleshed example.

## Project conventions (mandatory)

These match the existing `lib/features/auth/presentation/bloc/`. **Follow them exactly:**

1. **Three independent files** — `_event.dart` and `_state.dart` are NOT `part of '<name>_bloc.dart';`. Each file imports `package:equatable/equatable.dart` and any entities it needs. The Bloc imports both event + state files explicitly.
2. **Imports in `_bloc.dart`** — `flutter_bloc`, the use case imports, `AppLogger` (for diagnostic logging if needed), the relative `_event.dart` + `_state.dart` imports.
3. **Equatable event hierarchy** — `abstract class <Feature>Event extends Equatable { const <Feature>Event(); @override List<Object?> get props => []; }` + concrete subclasses with `final` fields and `props` lists.
4. **Equatable state hierarchy with multiple subclasses** — `abstract class <Feature>State extends Equatable { ... }` + `<Feature>Initial`, `<Feature>Loading`, `<Feature>Loaded`, `<Feature>Error`, and feature-specific subclasses. **NOT** a single `<Feature>State` class with a `status` enum.
5. **Bloc constructor injection** — `<Feature>Bloc({required <UseCase>UseCase ...})` with each use case as a `required` named parameter, assigned to a private field via colon-initializer-list. Initial state passed to `super(...)`.
6. **Async work via `Either.fold`** — every async use case call follows the pattern:
   ```dart
   final result = await _useCase(<UseCase>Params(/* ... */));
   result.fold(
     (failure) => emit(<Feature>Error(failure.message)),
     (data) => emit(<Feature>Loaded(data)),
   );
   ```
   Never raw `try { ... } catch (e) { ... }`. The repository's `RepositoryMixin.safeRemoteCall` already handles exception-to-Failure mapping.
7. **`AppLogger` for diagnostic logs** — `AppLogger.info(...)`, `AppLogger.warning(...)`, `AppLogger.error(...)` from `package:autogram/core/utils/app_logger.dart`. Never `print` / `debugPrint`.
8. **Translations via `easy_localization`** — UI-facing error messages should generally come from the `Failure.message` (already populated). If the bloc generates a message itself, use `'errors.<key>'.tr()`.
9. **No `freezed`, no `injectable`, no `json_serializable`** in production code without explicit user approval — they're declared in `dev_dependencies` but unused; introducing the first one is a convention change.
10. **No `Cubit`, no `BlocSelector`, no DI lookup in field initializer** — event-driven `Bloc` only, with `BlocBuilder` + `buildWhen`, and constructor injection.

## Steps

1. **Read the reference**: `reference/auth_bloc_example.md` to internalize the canonical pattern.
2. **Confirm inputs** with the user (the 4 items above).
3. **Generate** the 3 files from templates, substituting:
   - `{{Feature}}` → PascalCase (`ForgotPassword`)
   - `{{feature}}` → snake_case (`forgot_password`)
   - `{{useCaseImports}}` → block of `import 'package:autogram/features/<name>/domain/usecases/<verb>_<feature>_usecase.dart';` lines
   - `{{useCaseFields}}` → block of `final <UseCase>UseCase _<useCase>UseCase;` lines
   - `{{useCaseConstructorParams}}` → block of `required <UseCase>UseCase <useCase>UseCase,` lines (with trailing comma)
   - `{{useCaseConstructorAssignments}}` → block of `_<useCase>UseCase = <useCase>UseCase,` lines (separated by `,`)
   - `{{eventBindings}}` → block of `on<<Feature><Verb>Requested>(_on<Verb>Requested);` lines
   - `{{eventClasses}}` → list of concrete events
   - `{{stateClasses}}` → list of concrete state subclasses, with `Loaded` carrying the payload
4. **Verify** the files compile: ask the user to run `flutter analyze` or run it via Bash if permitted. Do not mark the task done until analyzer is clean.
5. **Wire up to UI** — remind the user that:
   - The Bloc must be registered in `lib/di/injection.dart` as `sl.registerFactory(() => <Feature>Bloc(<deps>: sl(), ...));` inside the matching `_init<Feature>()` function. Use the `flutter-di-register` skill to do this mechanically.
   - The screen wraps it via `BlocProvider(create: (_) => sl<<Feature>Bloc>())`.
   - The screen reacts via `BlocConsumer<<Feature>Bloc, <Feature>State>` with `listenWhen: (p, c) => p.runtimeType != c.runtimeType` (since states are a subclass hierarchy).

## Anti-patterns (reject if requested)

- Generating a Bloc that uses `part` / `part of` — the project explicitly uses **separate files with imports**.
- Generating a Bloc with `@freezed` annotations — the project does not use freezed.
- Generating a single `<Feature>State` class with a `status` enum — the project uses a class hierarchy.
- Generating a Bloc with field-initializer DI lookup (`final foo = sl<Foo>();`) — the project uses constructor injection.
- Generating raw `try / catch` around use case calls — the project uses `Either.fold`.
- Inserting `print()` / `debugPrint()` calls — use `AppLogger`.
- Storing `BuildContext` or other widget-side references in state.
- Doing API calls directly from the Bloc — must go through a `UseCase`.
- Using `setState`-style imperative API — this is BLoC, all state via `emit()`.
