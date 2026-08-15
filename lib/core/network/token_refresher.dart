import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../constants/api_paths.dart';
import 'auth_session.dart';
import 'secure_token_storage.dart';

/// Refreshes the access token using the stored refresh token.
///
/// Uses its own bare [Dio] instance (no interceptors) so it can never
/// recursively trigger [AuthInterceptor]'s 401 handling.
@lazySingleton
class TokenRefresher {
  TokenRefresher(this._authSession, this._tokenStorage)
      : _refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  final AuthSession _authSession;
  final SecureTokenStorage _tokenStorage;
  final Dio _refreshDio;

  Completer<bool>? _inFlightRefresh;

  /// Ensures only one refresh call is in flight at a time; concurrent
  /// callers await the same result instead of firing duplicate requests.
  Future<bool> refresh() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing.future;

    final completer = Completer<bool>();
    _inFlightRefresh = completer;
    _doRefresh().then(completer.complete).catchError((Object _) {
      completer.complete(false);
    }).whenComplete(() {
      _inFlightRefresh = null;
    });
    return completer.future;
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiPaths.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data == null) return false;

      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      if (newAccessToken == null || newRefreshToken == null) return false;

      _authSession.setAccessToken(newAccessToken);
      await _tokenStorage.saveRefreshToken(newRefreshToken);
      return true;
    } on DioException {
      return false;
    }
  }
}
