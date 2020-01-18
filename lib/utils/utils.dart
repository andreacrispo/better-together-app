import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';


final String DEFAULT_ICON = "default";

class HexColor extends Color {

  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return int.parse("0x$hexColor");
    }

    return int.parse("0xffffffff");
  }

  HexColor(final String hexColor) : super(getColorFromHex(hexColor));
}


Map<String, List<String>> localeMonthString = {

  "en": [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ],

  "it": [
    '',
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre'
  ]
};



Map<String, dynamic> rates =  {
  "CAD": 1.4498,
  "HKD": 8.6292,
  "ISK": 137.4,
  "PHP": 56.548,
  "DKK": 7.4729,
  "HUF": 335.59,
  "CZK": 25.147,
  "AUD": 1.6122,
  "RON": 4.7803,
  "SEK": 10.545,
  "IDR": 15184.91,
  "INR": 78.9567,
  "BRL": 4.639,
  "RUB": 68.2495,
  "HRK": 7.4378,
  "JPY": 122.31,
  "THB": 33.746,
  "CHF": 1.0736,
  "SGD": 1.496,
  "PLN": 4.2367,
  "BGN": 1.9558,
  "TRY": 6.5323,
  "CNY": 7.6186,
  "NOK": 9.889,
  "NZD": 1.6782,
  "ZAR": 16.0582,
  "USD": ["\$", 'US Dollar'],
  "EUR": ["€", "Euro"],
  "MXN": 20.8338,
  "ILS": 3.8372,
  "GBP": 0.85105,
  "KRW": 1288.37,
  "MYR": 4.5041
};

String i18n(context, placeholder) => FlutterI18n.translate(context, placeholder);



bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}


Timestamp getTimestamp(yearPaid, monthPaid) {
  return Timestamp.fromDate(DateTime(yearPaid, monthPaid));
}
