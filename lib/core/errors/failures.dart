sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi internet bermasalah']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server mengalami gangguan. Coba lagi nanti']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Email atau password salah']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data tidak ditemukan']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Gagal menyimpan data']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan tidak terduga']);
}
