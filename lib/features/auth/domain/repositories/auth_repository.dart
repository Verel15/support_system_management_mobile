import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({required String email, required String password});

  /// Called on app start. Uses the stored refresh token (if any) to obtain
  /// a fresh access token and the current user, without prompting login.
  Future<Either<Failure, User>> restoreSession();

  Future<Either<Failure, Unit>> logout();
}
