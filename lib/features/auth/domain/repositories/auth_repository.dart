import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, SeaUser>> signIn({required String email, required String password});
  Future<Either<Failure, SeaUser>> signUp({required String email, required String password});
  Future<Either<Failure, Unit>> signInWithGoogle();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Unit>> sendPasswordReset(String email);
  SeaUser? get currentUser;
  Stream<SeaUser?> get authStateChanges;
}
