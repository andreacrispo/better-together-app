import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Color hexToColor(String code, Color defaultColor) {
  try {
    return new Color(int.parse(code, radix: 16) + 0xFF000000);
  } catch (Ex) {
    print("hexToColor EX" + Ex.toString());
    return defaultColor;
  }
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

SnackBar createSnackBar(String text) {
  return SnackBar(
    content: Text(text),
    /*
     action: SnackBarAction(
       label: 'Undo',
       onPressed: () {
         // Some code to undo the change.
       },
     ),
     */
  );
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}


Timestamp getTimestamp(yearPaid, monthPaid) {
  return Timestamp.fromDate(DateTime(yearPaid, monthPaid));
}
