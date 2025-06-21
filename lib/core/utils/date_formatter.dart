import 'package:intl/intl.dart';

class DateFormatter {
  static String formatOrderDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  static String formatDeliveryDate(DateTime orderDate) {
    // Assuming delivery is same day for this example
    return DateFormat('yyyy-MM-dd').format(orderDate);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }
}
