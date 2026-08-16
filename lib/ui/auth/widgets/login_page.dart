import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formz/formz.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/brand_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_form_inputs.dart';
import 'login_visuals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Email _email = const Email.pure();
  Password _password = const Password.pure();
  bool _submitted = false;
  bool _obscurePassword = true;

  bool get _isValid => Formz.validate([_email, _password]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [BrandColors.backgroundStart, BrandColors.backgroundEnd],
          // ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated && state.message != null && _submitted) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message!)));
            }
          },
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandHeader(),
                      const SizedBox(height: 40),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to continue to your account',
                        style: TextStyle(color: BrandColors.muted),
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        hintText: 'Email',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        errorText: _submitted && _email.isNotValid ? 'Enter a valid email' : null,
                        onChanged: (value) => setState(() => _email = Email.dirty(value)),
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        hintText: 'Password',
                        icon: LucideIcons.lock,
                        obscureText: _obscurePassword,
                        errorText: _submitted && _password.isNotValid
                            ? 'Password must be at least 8 characters'
                            : null,
                        onChanged: (value) => setState(() => _password = Password.dirty(value)),
                        trailing: IconButton(
                          icon: Icon(
                            _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                            color: BrandColors.fieldIcon,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthAuthenticating;
                          return GradientButton(
                            label: 'Log In',
                            loading: isLoading,
                            onPressed: isLoading ? null : _onSubmit,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const OrDivider(),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        label: 'Continue with Google',
                        icon: SvgPicture.asset('assets/icons/google.svg', width: 20, height: 20),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        label: 'Continue with Apple',
                        icon: SvgPicture.asset('assets/icons/apple.svg', width: 20, height: 20),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: BrandColors.muted)),
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () {},
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    setState(() {
      _submitted = true;
      _email = Email.dirty(_email.value);
      _password = Password.dirty(_password.value);
    });
    if (!_isValid) return;

    context.read<AuthBloc>().add(
          AuthEvent.loginRequested(email: _email.value, password: _password.value),
        );
  }
}
