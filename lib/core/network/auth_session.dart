import 'dart:async';

import 'package:injectable/injectable.dart';

/// Holds the current access token in memory only (never persisted to disk).
/// Refresh token lives in secure storage, owned by `AuthRepository` — this
/// class is intentionally feature-agnostic so `core/` never depends on
/// `data/` or `ui/`.
@lazySingleton
class AuthSession {
  String? _accessToken;

  final StreamController<void> _forceLogoutController = StreamController<void>.broadcast();

  /// Emits when the session should be torn down (e.g. refresh token expired
  /// or was revoked). The app shell listens to this to redirect to /login.
  Stream<void> get onForceLogout => _forceLogoutController.stream;

  String? get accessToken => _accessToken;

  bool get isAuthenticated => _accessToken != null;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clear() {
    _accessToken = null;
  }

  void notifyForceLogout() {
    _accessToken = null;
    _forceLogoutController.add(null);
  }

  void dispose() {
    _forceLogoutController.close();
  }
}
