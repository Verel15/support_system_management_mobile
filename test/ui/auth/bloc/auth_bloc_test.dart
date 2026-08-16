import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:support_system_management_mobile/core/error/failure.dart';
import 'package:support_system_management_mobile/core/network/auth_session.dart';
import 'package:support_system_management_mobile/data/repositories/auth_repository.dart';
import 'package:support_system_management_mobile/domain/models/user.dart';
import 'package:support_system_management_mobile/ui/auth/bloc/auth_bloc.dart';
import 'package:support_system_management_mobile/ui/auth/bloc/auth_event.dart';
import 'package:support_system_management_mobile/ui/auth/bloc/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late AuthSession authSession;

  const user = User(id: '1', email: 'jane@example.com', name: 'Jane');

  setUp(() {
    repository = _MockAuthRepository();
    authSession = AuthSession();
  });

  AuthBloc buildBloc() => AuthBloc(repository, authSession);

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when session restore succeeds',
      setUp: () {
        when(() => repository.restoreSession()).thenAnswer((_) async => const Right(user));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthEvent.started()),
      expect: () => [const AuthState.authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when there is no stored session',
      setUp: () {
        when(() => repository.restoreSession())
            .thenAnswer((_) async => const Left(UnauthorizedFailure('No stored session')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthEvent.started()),
      expect: () => [const AuthState.unauthenticated()],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [authenticating, authenticated] on successful login',
      setUp: () {
        when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => const Right(user));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const AuthEvent.loginRequested(email: 'jane@example.com', password: 'secret123')),
      expect: () => [const AuthState.authenticating(), const AuthState.authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticating, unauthenticated(message)] on failed login',
      setUp: () {
        when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => const Left(UnauthorizedFailure('Invalid credentials')));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const AuthEvent.loginRequested(email: 'jane@example.com', password: 'wrong')),
      expect: () => [
        const AuthState.authenticating(),
        const AuthState.unauthenticated(message: 'Invalid credentials'),
      ],
    );
  });

  group('AuthSessionExpired', () {
    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when AuthSession forces logout',
      setUp: () {
        when(() => repository.restoreSession())
            .thenAnswer((_) async => const Left(UnauthorizedFailure('No stored session')));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const AuthEvent.started());
        await Future<void>.delayed(Duration.zero);
        authSession.notifyForceLogout();
      },
      skip: 1,
      expect: () => [
        const AuthState.unauthenticated(message: 'Session expired, please log in again'),
      ],
    );
  });
}
