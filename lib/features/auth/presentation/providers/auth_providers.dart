import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((_) => Supabase.instance.client);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, error: error);

  AuthState clearError() => AuthState(isLoading: isLoading);
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final result = await _repo.signIn(email: email, password: password);
    return result.fold(
      (failure) {
        state = AuthState(error: failure.message);
        return false;
      },
      (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final result = await _repo.signUp(email: email, password: password);
    return result.fold(
      (failure) {
        state = AuthState(error: failure.message);
        return false;
      },
      (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    final result = await _repo.signInWithGoogle();
    result.fold(
      (failure) => state = AuthState(error: failure.message),
      (_) => state = const AuthState(),
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true);
    final result = await _repo.sendPasswordReset(email);
    return result.fold(
      (failure) {
        state = AuthState(error: failure.message);
        return false;
      },
      (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }

  void clearError() => state = state.clearError();
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
