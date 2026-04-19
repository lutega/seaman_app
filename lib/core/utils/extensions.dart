import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toDisplayDate() => DateFormat('dd MMM yyyy', 'id').format(this);
  String toDisplayDateTime() => DateFormat('dd MMM yyyy, HH:mm', 'id').format(this);

  int daysUntil() => difference(DateTime.now()).inDays;

  bool get isExpired => isBefore(DateTime.now());
  bool get isExpiringSoon => !isExpired && daysUntil() <= 30;
  bool get isUrgent => !isExpired && daysUntil() <= 7;
}

extension CurrencyX on int {
  String toRupiah() {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }
}

extension StringX on String {
  String maskNik() {
    if (length != 16) return this;
    return '${substring(0, 4)} **** **** ****';
  }

  String formatNik() {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return digits;
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8, 12)} ${digits.substring(12)}';
  }
}
