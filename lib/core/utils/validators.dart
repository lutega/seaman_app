class SrValidators {
  SrValidators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != password) return 'Password tidak cocok';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName wajib diisi';
    return null;
  }

  static String? nik(String? value) {
    if (value == null || value.isEmpty) return 'NIK wajib diisi';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return 'NIK harus 16 digit angka';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Nomor HP wajib diisi';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 13) return 'Format nomor HP tidak valid';
    return null;
  }

  static String? seafarerNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[A-Za-z0-9]{6,8}$');
    if (!regex.hasMatch(value)) return 'Format nomor pelaut tidak valid (6-8 karakter alfanumerik)';
    return null;
  }

  static String? birthDate(String? value) {
    if (value == null || value.isEmpty) return 'Tanggal lahir wajib diisi';
    try {
      final date = DateTime.parse(value);
      final minAge = DateTime.now().subtract(const Duration(days: 17 * 365));
      if (date.isAfter(minAge)) return 'Usia minimal 17 tahun';
    } catch (_) {
      return 'Format tanggal tidak valid';
    }
    return null;
  }
}
