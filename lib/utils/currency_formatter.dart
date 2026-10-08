import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static String vnd(num amount) => _vnd.format(amount);
}
