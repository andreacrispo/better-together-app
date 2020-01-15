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


List<String> monthString = [
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
];


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
