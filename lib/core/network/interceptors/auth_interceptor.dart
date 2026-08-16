import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../auth_session.dart';
import '../token_refresher.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authSession, this._tokenRefresher);

  final AuthSession _authSession;
  final TokenRefresher _tokenRefresher;

  /// Set by [DioClient] right after constructing the [Dio] instance this
  /// interceptor is attached to, so a 401 retry can reuse the exact same
  /// client (base options, other interceptors, adapter) instead of building
  /// a throwaway one.
  Dio? _dio;

  void attach(Dio dio) => _dio = dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authSession.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retriedAfterRefresh'] == true;
    final dio = _dio;

    if (!isUnauthorized || alreadyRetried || dio == null) {
      return handler.next(err);
    }

    final refreshed = await _tokenRefresher.refresh();
    if (!refreshed) {
      _authSession.notifyForceLogout();
      return handler.next(err);
    }

    try {
      final retryOptions = err.requestOptions
        ..extra['retriedAfterRefresh'] = true
        ..headers['Authorization'] = 'Bearer ${_authSession.accessToken}';

      final response = await dio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }
}
