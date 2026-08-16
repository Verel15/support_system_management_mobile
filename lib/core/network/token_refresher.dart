import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../constants/api_paths.dart';
import 'auth_session.dart';

/// Refreshes the access token using the refresh token stored in an httpOnly
/// cookie — the app never reads its value, [CookieManager] attaches it to
/// the request automatically.
///
/// Uses its own bare [Dio] instance (no [AuthInterceptor]) so it can never
/// recursively trigger 401 handling.
@lazySingleton
class TokenRefresher {
  TokenRefresher(this._authSession, CookieJar cookieJar)
      : _refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))
          ..interceptors.add(CookieManager(cookieJar));

  final AuthSession _authSession;
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
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(ApiPaths.refresh);
      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      if (newAccessToken == null) return false;

      _authSession.setAccessToken(newAccessToken);
      return true;
    } on DioException {
      return false;
    }
  }
}
