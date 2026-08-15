import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/network/secure_token_storage.dart';
import '../../../../core/network/token_refresher.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._authSession,
    this._tokenStorage,
    this._tokenRefresher,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSession _authSession;
  final SecureTokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    try {
      final result = await _remoteDataSource.login(email: email, password: password);
      _authSession.setAccessToken(result.accessToken);
      await _tokenStorage.saveRefreshToken(result.refreshToken);
      return Right(result.user.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, User>> restoreSession() async {
    final hasRefreshToken = await _tokenStorage.readRefreshToken() != null;
    if (!hasRefreshToken) {
      return const Left(UnauthorizedFailure('No stored session'));
    }

    final refreshed = await _tokenRefresher.refresh();
    if (!refreshed) {
      await _tokenStorage.clearRefreshToken();
      return const Left(UnauthorizedFailure('Session expired'));
    }

    try {
      final user = await _remoteDataSource.fetchCurrentUser();
      return Right(user.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _remoteDataSource.logout();
    await _tokenStorage.clearRefreshToken();
    _authSession.clear();
    return const Right(unit);
  }
}
