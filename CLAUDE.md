# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Flutter mobile client for a support-ticket system, backed by a separate NestJS API (not in this repo). Dart SDK `^3.13.0`. No `.cursorrules`, Copilot instructions, or existing `CLAUDE.md` were present before this file.

## Commands

```bash
flutter pub get                        # install deps
flutter analyze                        # static analysis (must be clean before committing)
flutter test                           # run all tests
flutter test test/features/auth/presentation/bloc/auth_bloc_test.dart   # single test file
dart run build_runner build --delete-conflicting-outputs  # regenerate freezed/json_serializable/injectable code
dart run build_runner watch --delete-conflicting-outputs  # regen on save, during active dev

flutter run --dart-define-from-file=config/dev.json        # run against local NestJS (localhost:3000)
flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json
flutter build ipa --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json
```

Any time a `@freezed`, `@injectable`/`@lazySingleton`/`@module`, or `.g.dart`/`.json_serializable` model is added or changed, re-run `build_runner build` — the generated `.freezed.dart`, `.g.dart`, and `lib/core/di/injection.config.dart` files must stay in sync or the app won't compile.

`config/dev.json` is checked in with a localhost API URL. `config/staging.json` and `config/prod.json` are gitignored — copy from `config/staging.example.json` / `config/prod.example.json` and fill in real values before using them.

## Architecture

Feature-first Clean Architecture. Every feature under `lib/features/<name>/` has exactly three layers, and dependencies only point inward:

```
presentation → domain ← data
```

- `domain/entities` — plain Dart models, no JSON/Dio knowledge.
- `domain/repositories` — abstract interfaces only, implemented in `data/`.
- `domain/usecases` — one class per business action (e.g. `LoginUseCase`), calling into a repository interface.
- `data/datasources` — the only place that calls `Dio` directly.
- `data/models` — `freezed` + `json_serializable` classes mapping API JSON; each has a `toEntity()` extension mapping to the matching `domain/entities` type.
- `data/repositories` — implements the `domain/repositories` interface, converts `data/models` → `domain/entities` and low-level `Exception`s → `core/error/failure.dart` `Failure`s.
- `presentation/bloc` — `flutter_bloc` Bloc/Cubit per feature; events/states are `freezed` sealed unions.
- `presentation/pages`, `presentation/widgets` — UI.

Code shared across features lives only in `lib/core/`, never in `lib/features/`. `features/auth` is the fully-built reference implementation — copy its structure when adding a new feature (`features/tickets` currently only has an empty `presentation/pages/ticket_list_page.dart` placeholder and needs the rest built out).

### Dependency injection

`get_it` + `injectable`. Annotate classes with `@injectable` / `@lazySingleton` / `@Injectable(as: SomeInterface)`; `NetworkModule` in `lib/core/network/dio_client.dart` is an `@module` provider for the shared `Dio` instance. Everything is wired through `lib/core/di/injection.dart` (`configureDependencies()`, called once in `bootstrap.dart`), which calls the generated `init(getIt)` in `injection.config.dart`. Get instances via `getIt<T>()`, not manual constructor wiring.

### Auth / token handling

This is the part most likely to need care when touched:

- **Access token** lives only in memory, in `AuthSession` (`lib/core/network/auth_session.dart`) — never written to disk.
- **Refresh token** lives in `flutter_secure_storage`, wrapped by `SecureTokenStorage` (`lib/core/network/secure_token_storage.dart`).
- `AuthInterceptor` (`lib/core/network/interceptors/auth_interceptor.dart`) attaches the bearer token to every request and, on a 401, calls `TokenRefresher.refresh()` and retries the original request once. `TokenRefresher` (`lib/core/network/token_refresher.dart`) uses its own bare `Dio` instance (no interceptors) so the refresh call itself can never recursively trigger the 401 handler, and de-dupes concurrent refresh calls behind a single `Completer` so parallel requests don't each fire their own refresh.
- On unrecoverable refresh failure, `AuthSession.notifyForceLogout()` fires a stream that `AuthBloc` listens to and turns into `AuthEvent.sessionExpired()` → `AuthState.unauthenticated(message: ...)`.
- `core/network/` intentionally has **no dependency on `features/auth`** — this keeps the refresh/interceptor machinery reusable and avoids a DI cycle. `features/auth/data/repositories/auth_repository_impl.dart` reuses the same `SecureTokenStorage`/`AuthSession`/`TokenRefresher` for login/logout/session-restore rather than duplicating token logic.

### Routing

`go_router`, configured in `lib/core/router/app_router.dart`. The `redirect` callback reads `AuthBloc.state` (via a `GoRouterRefreshStream` wrapper around `authBloc.stream`, see `go_router_refresh_stream.dart`) to bounce unauthenticated users to `/login` and authenticated users away from `/login`.

### Error handling

`fpdart`'s `Either<Failure, T>` is the return type for every repository/usecase method — `Left(Failure)` or `Right(value)`. Don't throw across the domain/presentation boundary; catch `Exception`s (`core/error/exceptions.dart`) in the repository and convert to a `Failure` (`core/error/failure.dart`) there.

### Config / flavors

`lib/core/config/app_config.dart` reads `FLAVOR`, `API_BASE_URL`, `ENABLE_NETWORK_LOGS` via `String.fromEnvironment`/`bool.fromEnvironment`, populated from `config/<flavor>.json` at build/run time with `--dart-define-from-file`. Don't read env vars any other way.

## Security notes specific to this repo

- Android: `usesCleartextTraffic="false"` is set in `android/app/src/main/AndroidManifest.xml` — HTTP (non-TLS) API URLs will fail on Android by design.
- Android release builds have `isMinifyEnabled`/`isShrinkResources` on with `android/app/proguard-rules.pro` — check this file if a release build strips something it shouldn't.
- `PrettyDioLogger` in `dio_client.dart` has `requestHeader: false` specifically so the `Authorization` bearer token never lands in logs — don't flip that to `true`.
- Never persist the access token; only the refresh token belongs in `SecureTokenStorage`.
