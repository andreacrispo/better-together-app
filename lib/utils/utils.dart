import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';


// ignore: constant_identifier_names
const String DEFAULT_ICON = "default";

class HexColor extends Color {

  HexColor(final String hexColor) : super(getColorFromHex(hexColor));

  static int getColorFromHex(String stringColor) {
    if(stringColor == null)
      return int.parse("0xffffffff");

    String hexColor = stringColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return int.parse("0x$hexColor");
    }

    return int.parse("0xffffffff");
  }

  static String from(Color color) {
    return '#${color.value.toRadixString(16)}';
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



class Currency {

  Currency(this.symbol, this.description, {this.icon = ""});
  String symbol;
  String description;
  String icon;
}


Map<String, Currency> currenciesMap =  {
  "CAD": Currency("\$", 'Canadian dollar'),
  "HKD": Currency("\$", 'Hong Kong Dollar'),
  "ISK": Currency("kr", 'Icelandic króna'),
  "PHP": Currency("₱", 'Philippine peso'),
  "DKK": Currency("kr", 'Danish krone'),
  "HUF": Currency("Ft", 'Hungarian forint'),
  "CZK": Currency("Kč", 'Czech koruna'),
  "AUD": Currency("\$", 'Australian dollar'),
  "RON": Currency("lei", 'Romanian leu'),
  "USD": Currency("\$", 'US Dollar'),
  "EUR": Currency("€", "Euro"),
  "SEK": Currency("kr", 'Swedish krona'),
  "NOK": Currency("kr", 'Norwegian krone'),
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


Currency getCurrency(String currencyCode) {
  return currencyCode != null
      ? currenciesMap[currencyCode]
      : currenciesMap["EUR"];
}

String getCurrencySymbol(String currencyCode) {
  return getCurrency(currencyCode).symbol;
}

String getCurrencyDescription(String currencyCode) {
  return getCurrency(currencyCode).description;
}

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

