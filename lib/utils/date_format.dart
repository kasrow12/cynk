import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final lastWeek = today.subtract(const Duration(days: 6));

  if (date.isAfter(today)) {
    return DateFormat.Hm().format(date);
  }
  if (date.isAfter(lastWeek)) {
    return DateFormat.E().format(date);
  }

  return DateFormat('dd.MM').format(date);
}
