import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  /// App just started; restoring session from stored refresh token.
  const factory AuthState.initial() = AuthInitial;

  const factory AuthState.authenticating() = AuthAuthenticating;

  const factory AuthState.authenticated(User user) = AuthAuthenticated;

  const factory AuthState.unauthenticated({String? message}) = AuthUnauthenticated;
}
