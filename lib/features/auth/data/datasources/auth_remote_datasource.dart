import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_paths.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login({required String email, required String password});
  Future<UserModel> fetchCurrentUser();
  Future<void> logout();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponseModel> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiPaths.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiPaths.me);
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

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
