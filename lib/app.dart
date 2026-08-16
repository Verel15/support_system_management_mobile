import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/storage/onboarding_storage.dart';
import 'ui/auth/bloc/auth_bloc.dart';
import 'ui/auth/bloc/auth_event.dart';
import 'ui/core/themes/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthEvent.started()),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final router = buildAppRouter(authBloc, getIt<OnboardingStorage>());

          return MaterialApp.router(
            title: 'Support System',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
