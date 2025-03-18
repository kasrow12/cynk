import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          DateFormat('d MMMM', Localizations.localeOf(context).languageCode)
              .format(date),
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
