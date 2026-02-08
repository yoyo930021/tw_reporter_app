import 'package:intl/intl.dart';

/// Unified date formatting utility.
String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy年MM月dd日');
  return formatter.format(date);
}
