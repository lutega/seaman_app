import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa_user show User;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<Either<Failure, SeaUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      final user = res.user;
      if (user == null) return left(const AuthFailure());
      return right(_mapUser(user));
    } on supa.AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, SeaUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(email: email, password: password);
      final user = res.user;
      if (user == null) return left(const ServerFailure());
      return right(_mapUser(user));
    } on supa.AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
      return right(unit);
    } catch (_) {
      return left(const ServerFailure('Gagal masuk dengan Google'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _client.auth.signOut();
      return right(unit);
    } catch (_) {
      return left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return right(unit);
    } on supa.AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  SeaUser? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Stream<SeaUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  SeaUser _mapUser(supa_user.User user) => SeaUser(
        id: user.id,
        email: user.email ?? '',
        emailConfirmed: user.emailConfirmedAt != null,
      );
}
