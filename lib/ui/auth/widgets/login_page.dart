import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_form_inputs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Email _email = const Email.pure();
  Password _password = const Password.pure();
  bool _submitted = false;

  bool get _isValid => Formz.validate([_email, _password]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Sign in', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    TextField(
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _submitted && _email.isNotValid
                            ? 'Enter a valid email'
                            : null,
                      ),
                      onChanged: (value) => setState(() => _email = Email.dirty(value)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _submitted && _password.isNotValid
                            ? 'Password must be at least 8 characters'
                            : null,
                      ),
                      onChanged: (value) => setState(() => _password = Password.dirty(value)),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthAuthenticating;
                        return FilledButton(
                          onPressed: isLoading ? null : _onSubmit,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign in'),
                        );
                      },
                    ),
                  ],
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
