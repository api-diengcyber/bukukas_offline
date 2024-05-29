import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';

final CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(
  NumberFormat.currency(
    decimalDigits: 0,
    locale: 'id',
    symbol: 'Rp',
  ),
  enableNegative: false,
);

final simpleFormatCurrency = NumberFormat.simpleCurrency(
  locale: 'id_ID',
  decimalDigits: 0,
);

currencyToDoubleString(String data) {
  data = data.replaceAll('Rp', '');
  data = data.replaceAll('.', '');
  return data;
}
