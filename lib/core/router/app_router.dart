import 'package:go_router/go_router.dart';

import '../../ui/auth/bloc/auth_bloc.dart';
import '../../ui/auth/bloc/auth_state.dart';
import '../../ui/auth/widgets/login_page.dart';
import '../../ui/tickets/widgets/ticket_list_page.dart';
import 'go_router_refresh_stream.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/api/v1/auth/login';
  static const String tickets = '/tickets';
}

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.tickets,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      switch (authState) {
        case AuthInitial():
        case AuthAuthenticating():
          return null; // stay put while we determine auth status
        case AuthAuthenticated():
          return isLoggingIn ? AppRoutes.tickets : null;
        case AuthUnauthenticated():
          return isLoggingIn ? null : AppRoutes.login;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.tickets,
        builder: (context, state) => const TicketListPage(),
      ),
    ],
  );
}
