import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../widgets/state_views.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

/// Root of the app: shows the login flow or the main shell depending on the
/// Firebase auth state. Rebuilds automatically on sign-in / sign-out.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user == null ? const LoginScreen() : const MainShell(),
      loading: () => const SplashView(),
      error: (error, _) => Scaffold(
        body: ErrorView(
          message: 'Could not reach the authentication service.\n$error',
          onRetry: () => ref.invalidate(authStateProvider),
        ),
      ),
    );
  }
}
