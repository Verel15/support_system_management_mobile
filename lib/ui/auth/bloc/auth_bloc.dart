import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/auth_session.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._authSession) : super(const AuthState.initial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    _forceLogoutSubscription = _authSession.onForceLogout.listen((_) {
      add(const AuthEvent.sessionExpired());
    });
  }

  final AuthRepository _repository;
  final AuthSession _authSession;

  late final StreamSubscription<void> _forceLogoutSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final result = await _repository.restoreSession();
    result.match(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    final result = await _repository.login(email: event.email, password: event.password);
    result.match(
      (failure) => emit(AuthState.unauthenticated(message: failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    emit(const AuthState.unauthenticated(message: 'Session expired, please log in again'));
  }

  @override
  Future<void> close() {
    _forceLogoutSubscription.cancel();
    return super.close();
  }
}
