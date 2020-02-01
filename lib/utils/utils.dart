import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';


// ignore: constant_identifier_names
const String DEFAULT_ICON = "default";

class HexColor extends Color {

  HexColor(final String hexColor) : super(getColorFromHex(hexColor));

  static int getColorFromHex(String stringColor) {
    String hexColor = stringColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return int.parse("0x$hexColor");
    }

    return int.parse("0xffffffff");
  }

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



Map<String, List<String>> currenciesMap =  {
  "CAD": ["\$", 'Canadian dollar'],
  "HKD": ["\$", 'Hong Kong Dollar'],
  "ISK": ["kr", 'Icelandic króna'],
  "PHP": ["₱", 'Philippine peso'],
  "DKK": ["kr", 'Danish krone'],
  "HUF": ["Ft", 'Hungarian forint'],
  "CZK": ["Kč", 'Czech koruna'],
  "AUD": ["\$", 'Australian dollar'],
  "RON": ["lei", 'Romanian leu'],
  "USD": ["\$", 'US Dollar'],
  "EUR": ["€", "Euro"],
  "SEK": ["kr", 'Swedish krona'],
  "NOK": ["kr", 'Norwegian krone'],
  /*
  "IDR": ["\$", 'US Dollar'],
  "INR": ["\$", 'US Dollar'],
  "BRL": ["\$", 'US Dollar'],
  "RUB": ["\$", 'US Dollar'],
  "HRK": ["\$", 'US Dollar'],
  "JPY": ["\$", 'US Dollar'],
  "THB": ["\$", 'US Dollar'],
  "CHF": ["\$", 'US Dollar'],
  "SGD": ["\$", 'US Dollar'],
  "PLN": ["\$", 'US Dollar'],
  "BGN": ["\$", 'US Dollar'],
  "TRY": ["\$", 'US Dollar'],
  "CNY": ["\$", 'US Dollar'],
  "NZD": ["\$", 'US Dollar'],
  "ZAR": ["\$", 'US Dollar'],
  "MXN": ["\$", 'US Dollar'],
  "ILS": ["\$", 'US Dollar'],
  "GBP": ["\$", 'US Dollar'],
  "KRW": ["\$", 'US Dollar'],
  "MYR": ["\$", 'US Dollar'],
  */
};

String i18n(BuildContext context, String placeholder) => FlutterI18n.translate(context, placeholder);


bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s) != null;
}


Timestamp getTimestamp(int yearPaid, int monthPaid) {
  return Timestamp.fromDate(DateTime(yearPaid, monthPaid));
}
