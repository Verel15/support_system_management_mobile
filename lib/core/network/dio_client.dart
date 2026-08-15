import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

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
