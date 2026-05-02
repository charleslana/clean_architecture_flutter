import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../view_models/login_viewmodel.dart';

/// Login screen for the mock auth.
///
/// On successful login the screen explicitly navigates to [from] (the URL
/// the user was originally trying to reach when the redirect bounced them
/// here) — falling back to `/` when there is no `from`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel, this.from});

  final LoginViewModel viewModel;
  final String? from;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Pre-fill with the mock credentials so it's obvious how to "log in".
  final _userController = TextEditingController(text: 'admin');
  final _passController = TextEditingController(text: 'admin');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mock auth — try admin / admin.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Listens to the ViewModel itself so it rebuilds whenever
              // `passwordVisible` flips. The TextEditingController is kept
              // outside the builder to preserve the user's text across
              // rebuilds.
              ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final visible = widget.viewModel.passwordVisible;
                  return TextFormField(
                    controller: _passController,
                    obscureText: !visible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: visible ? 'Hide password' : 'Show password',
                        icon: Icon(
                          visible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: widget.viewModel.togglePasswordVisibility,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              ListenableBuilder(
                listenable: widget.viewModel.login,
                builder: (context, _) {
                  final running = widget.viewModel.login.running;
                  final hadError = widget.viewModel.login.error;
                  final result = widget.viewModel.login.result;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        icon: running
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(running ? 'Logging in…' : 'Login'),
                        onPressed: running ? null : _onSubmit,
                      ),
                      if (hadError && result is Error<void>) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Login failed: ${errorMessageFor(result.error)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.viewModel.login.execute((
      username: _userController.text,
      password: _passController.text,
    ));
    if (!mounted) return;

    if (widget.viewModel.login.completed) {
      // Send the user back to where they were heading when the gate kicked
      // in. If they came here directly (no redirect), default to `/`.
      context.go(widget.from ?? Routes.home);
    }
  }
}
