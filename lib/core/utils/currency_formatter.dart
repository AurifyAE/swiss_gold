import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatAED(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'AED ${formatter.format(amount)}';
  }

  static String getCurrentRate() {
    // This would typically come from an API or state management
    return '397.91';
  }

  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(number);
  }
}