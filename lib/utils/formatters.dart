import 'package:intl/intl.dart';

final _peso = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
final _date = DateFormat('MMM d, y');

String peso(num value) => _peso.format(value);
String shortDate(DateTime value) => _date.format(value);
