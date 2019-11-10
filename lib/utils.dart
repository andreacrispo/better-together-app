

import 'dart:ui';

import 'package:flutter/material.dart';

Color hexToColor(String code) {
  if(code.length < 7)
    return Colors.white;

  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}


List<String> monthString = ['', 'Gennaio', 'Febbrario', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];

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