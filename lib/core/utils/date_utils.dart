import 'package:intl/intl.dart';

/// Utility helpers used across the app.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayFormat =
      DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _shortFormat = DateFormat('dd MMM yyyy');
  static final NumberFormat _currencyFormat =
      NumberFormat('#,##0.00', 'en_ZM');

  /// Formats a [DateTime] as "dd MMM yyyy, HH:mm".
  static String formatDateTime(DateTime dt) => _displayFormat.format(dt);

  /// Formats a [DateTime] as "dd MMM yyyy".
  static String formatDate(DateTime dt) => _shortFormat.format(dt);

  /// Formats an ISO-8601 string stored in SQLite to a display string.
  static String formatIso(String iso) {
    try {
      return formatDateTime(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  /// Formats a monetary amount in ZMW.
  static String formatCurrency(double amount) =>
      'ZMW ${_currencyFormat.format(amount)}';
}
