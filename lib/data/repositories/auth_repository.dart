import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../core/network/auth_session.dart';
import '../../core/network/token_refresher.dart';
import '../../domain/models/user.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';

@injectable
class AuthRepository {
  AuthRepository(this._apiService, this._authSession, this._tokenRefresher);

  final AuthApiService _apiService;
  final AuthSession _authSession;
  final TokenRefresher _tokenRefresher;

  Future<Either<Failure, User>> login({required String email, required String password}) async {
    try {
      final result = await _apiService.login(email: email, password: password);
      _authSession.setAccessToken(result.accessToken);
      final user = await _apiService.fetchCurrentUser();
      return Right(user.toDomain());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  /// Called on app start. Uses the refresh token stored in an httpOnly
  /// cookie (if any) to obtain a fresh access token and the current user,
  /// without prompting login.
  Future<Either<Failure, User>> restoreSession() async {
    final refreshed = await _tokenRefresher.refresh();
    if (!refreshed) {
      return const Left(UnauthorizedFailure('Session expired'));
    }

    try {
      final user = await _apiService.fetchCurrentUser();
      return Right(user.toDomain());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, Unit>> logout() async {
    await _apiService.logout();
    _authSession.clear();
    return const Right(unit);
  }
}
