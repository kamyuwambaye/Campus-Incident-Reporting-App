import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'firebase_providers.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);

/// Raw Firebase user. `null` means signed out.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);

/// Live profile document for the signed-in user (name, role, department).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value(null);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    return data == null ? null : AppUser.fromMap(doc.id, data);
  });
});

/// Convenience: `true` only when the profile document says role == 'staff'.
/// Security rules make the same check server-side, so this is purely for UI.
final isStaffProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider).asData?.value?.isStaff ?? false,
);

/// Drives sign-in / sign-up / sign-out and exposes loading + error state.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn({required String email, required String password}) =>
      _run(() => ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          ));

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String department,
  }) =>
      _run(() => ref.read(authServiceProvider).signUp(
            name: name,
            email: email,
            password: password,
            department: department,
          ));

  Future<bool> signOut() => _run(() => ref.read(authServiceProvider).signOut());

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
