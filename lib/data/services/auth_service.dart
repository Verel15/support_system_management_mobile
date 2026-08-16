import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_paths.dart';
import '../../core/error/exceptions.dart';
import '../model/login_response_model.dart';
import '../model/user_model.dart';

abstract interface class AuthApiService {
  Future<LoginResponseModel> login({required String email, required String password});
  Future<UserModel> fetchCurrentUser();
  Future<void> logout();
}

@Injectable(as: AuthApiService)
class AuthApiServiceImpl implements AuthApiService {
  AuthApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponseModel> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiPaths.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(_unwrap(response));
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiPaths.me);
      return UserModel.fromJson(_unwrap(response));
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// API responses are wrapped as `{ success, message, data }` — unwrap
  /// `data` before decoding into a model.
  Map<String, dynamic> _unwrap(Response<Map<String, dynamic>> response) =>
      response.data!['data'] as Map<String, dynamic>;

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiPaths.logout);
    } on DioException {
      // Best-effort server-side revocation; local session is cleared
      // regardless by the repository.
    }
  }

  Exception _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return const UnauthorizedException();
    }
    final message = (e.response?.data is Map)
        ? (e.response?.data['message']?.toString() ?? e.message ?? 'Server error')
        : (e.message ?? 'Server error');
    return ServerException(message, statusCode: statusCode);
  }
}
