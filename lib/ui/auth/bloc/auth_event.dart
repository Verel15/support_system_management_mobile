import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  /// Dispatched once on app start to try restoring a session from the
  /// stored refresh token.
  const factory AuthEvent.started() = AuthStarted;

  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = AuthLoginRequested;

  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;

  /// Internal event fired when [AuthSession.onForceLogout] emits (refresh
  /// token expired/revoked mid-session).
  const factory AuthEvent.sessionExpired() = AuthSessionExpired;
}
