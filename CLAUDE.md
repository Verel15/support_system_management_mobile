# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Flutter mobile client for a support-ticket system, backed by a separate NestJS API (not in this repo). Dart SDK `^3.13.0`. No `.cursorrules`, Copilot instructions, or existing `CLAUDE.md` were present before this file.

## Commands

```bash
flutter pub get                        # install deps
flutter analyze                        # static analysis (must be clean before committing)
flutter test                           # run all tests
flutter test test/ui/auth/bloc/auth_bloc_test.dart      # single test file
dart run build_runner build --delete-conflicting-outputs  # regenerate freezed/json_serializable/injectable code
dart run build_runner watch --delete-conflicting-outputs  # regen on save, during active dev

flutter run --dart-define-from-file=config/dev.json        # run against local NestJS (localhost:3000)
flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json
flutter build ipa --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json
```

Any time a `@freezed`, `@injectable`/`@lazySingleton`/`@module`, or `.g.dart`/`.json_serializable` model is added or changed, re-run `build_runner build` — the generated `.freezed.dart`, `.g.dart`, and `lib/core/di/injection.config.dart` files must stay in sync or the app won't compile.

`config/dev.json` is checked in with a localhost API URL. `config/staging.json` and `config/prod.json` are gitignored — copy from `config/staging.example.json` / `config/prod.example.json` and fill in real values before using them.

## Architecture

Layer-first, modeled on Flutter's official [app-architecture case study](https://docs.flutter.dev/app-architecture/case-study), adapted for a client with no local persistence (this app only ever calls and reacts to the NestJS API — there's no on-device database, so the data layer stays thin):

```
lib/
  ui/<feature>/bloc/      flutter_bloc Bloc/Cubit; events/states are freezed sealed unions
  ui/<feature>/widgets/   pages and widgets for that feature
  ui/core/                shared widgets and themes (ui/core/themes/app_theme.dart)
  domain/models/          plain Dart entities, no JSON/Dio knowledge — shared across all features
  data/repositories/      concrete classes (no abstract interface) called directly by blocs;
                           convert data/model → domain/models and low-level Exceptions →
                           core/error/failure.dart Failures
  data/services/          the only place that calls Dio directly (one abstract interface +
                           Impl per service, e.g. AuthApiService/AuthApiServiceImpl, so
                           repositories can be unit-tested against a mock)
  data/model/              freezed + json_serializable classes mapping API JSON; each has a
                           toDomain() extension mapping to the matching domain/models type
  core/                   cross-cutting infra not tied to any feature — network, DI, router,
                           error, config, constants (see below)
```

Unlike the official case study, `domain/` holds **only models** — no repository interfaces, no usecases. Blocs call repository classes directly; there's no interface to implement because this app has exactly one data source (the NestJS API) per repository, so an interface would have no second implementation to justify it. Repositories are still unit-testable by mocking their `data/services/*Service` dependency (which does keep an interface, for that reason).

Feature folders live only under `ui/<feature>/` — `data/` and `domain/` are organized by type, not feature, and are shared across features. `ui/auth/` is the fully-built reference implementation — copy its structure when adding a new feature (`ui/tickets/` currently only has an empty `widgets/ticket_list_page.dart` placeholder and needs a bloc + real data layer built out).

### Dependency injection

`get_it` + `injectable`. Annotate classes with `@injectable` / `@lazySingleton` / `@Injectable(as: SomeInterface)`; `NetworkModule` in `lib/core/network/dio_client.dart` is an `@module` provider for the shared `Dio` instance. Everything is wired through `lib/core/di/injection.dart` (`configureDependencies()`, called once in `bootstrap.dart`), which calls the generated `init(getIt)` in `injection.config.dart`. Get instances via `getIt<T>()`, not manual constructor wiring.

### Auth / token handling

This is the part most likely to need care when touched:

- **Access token** lives only in memory, in `AuthSession` (`lib/core/network/auth_session.dart`) — never written to disk.
- **Refresh token** is set by the API as an **httpOnly cookie** — the app never reads its value. A shared `CookieJar` (`cookie_jar` + `dio_cookie_manager`, provided by `NetworkModule` in `lib/core/network/dio_client.dart` via a `@preResolve` async singleton) persists it to app-private storage and attaches it to requests automatically. This storage is OS-sandboxed but **not encrypted at rest**, unlike the `flutter_secure_storage`-backed approach it replaced — a deliberate trade-off forced by the API's cookie-based contract, not a free choice.
- Every API response is wrapped as `{ success, message, data }`; `data/services/*Service` implementations unwrap `data` before decoding into a model — don't `fromJson` a raw response body.
- Login (`POST /api/v1/auth/login`) returns only `{ accessToken, tokenType, userId }`, not a full user profile — `AuthRepository.login()` sets the access token, then makes a follow-up `GET /api/v1/auth/me` call to get the full `User`. `restoreSession()` does the same after a successful refresh.
- `AuthInterceptor` (`lib/core/network/interceptors/auth_interceptor.dart`) attaches the bearer token to every request and, on a 401, calls `TokenRefresher.refresh()` and retries the original request once. `TokenRefresher` (`lib/core/network/token_refresher.dart`) uses its own bare `Dio` instance (no `AuthInterceptor`, but the same shared `CookieJar` so the refresh cookie still goes out) so the refresh call itself can never recursively trigger the 401 handler, and de-dupes concurrent refresh calls behind a single `Completer` so parallel requests don't each fire their own refresh.
- On unrecoverable refresh failure, `AuthSession.notifyForceLogout()` fires a stream that `AuthBloc` listens to and turns into `AuthEvent.sessionExpired()` → `AuthState.unauthenticated(message: ...)`.
- `core/network/` intentionally has **no dependency on `ui/auth` or `data/repositories/auth_repository.dart`** — this keeps the refresh/interceptor machinery reusable and avoids a DI cycle. `data/repositories/auth_repository.dart` reuses the same `AuthSession`/`TokenRefresher` for login/logout/session-restore rather than duplicating token logic.

### Routing

`go_router`, configured in `lib/core/router/app_router.dart`. The `redirect` callback reads `AuthBloc.state` (via a `GoRouterRefreshStream` wrapper around `authBloc.stream`, see `go_router_refresh_stream.dart`) to bounce unauthenticated users to `/login` and authenticated users away from `/login`.

### Error handling

`fpdart`'s `Either<Failure, T>` is the return type for every repository method — `Left(Failure)` or `Right(value)`. Don't throw across the data/ui boundary; catch `Exception`s (`core/error/exceptions.dart`) in the repository and convert to a `Failure` (`core/error/failure.dart`) there.

### Config / flavors

`lib/core/config/app_config.dart` reads `FLAVOR`, `API_BASE_URL`, `ENABLE_NETWORK_LOGS` via `String.fromEnvironment`/`bool.fromEnvironment`, populated from `config/<flavor>.json` at build/run time with `--dart-define-from-file`. Don't read env vars any other way.

## Security notes specific to this repo

- Android: `usesCleartextTraffic="false"` is set in `android/app/src/main/AndroidManifest.xml` — HTTP (non-TLS) API URLs will fail on Android by design.
- Android release builds have `isMinifyEnabled`/`isShrinkResources` on with `android/app/proguard-rules.pro` — check this file if a release build strips something it shouldn't.
- `PrettyDioLogger` in `dio_client.dart` has `requestHeader: false` specifically so the `Authorization` bearer token never lands in logs — don't flip that to `true`.
- Never persist the access token — keep it in `AuthSession` (memory only). The refresh token is never handled directly by app code at all; it lives in the httpOnly cookie the API sets and `CookieJar` manages.
