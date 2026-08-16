import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';

@module
abstract class NetworkModule {
  /// The refresh token lives in an httpOnly cookie set by the API — the app
  /// never reads its value directly. This jar persists it to app-private
  /// storage so it survives restarts; unlike the previous
  /// `flutter_secure_storage`-backed approach, that storage is sandboxed but
  /// not encrypted at rest.
  @preResolve
  @lazySingleton
  Future<CookieJar> cookieJar() async {
    final dir = await getApplicationDocumentsDirectory();
    return PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
  }

  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor, CookieJar cookieJar) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(CookieManager(cookieJar));
    authInterceptor.attach(dio);
    dio.interceptors.add(authInterceptor);

    if (AppConfig.enableNetworkLogs) {
      dio.interceptors.add(
        // requestHeader is off so the Authorization bearer token never hits
        // the console, even in debug builds.
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    return dio;
  }
}
