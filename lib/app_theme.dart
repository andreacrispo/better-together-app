import 'package:flutter/material.dart';




const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006B58),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF7CF8D7),
  onPrimaryContainer: Color(0xFF002019),
  secondary: Color(0xFF006874),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF97F0FF),
  onSecondaryContainer: Color(0xFF001F24),
  tertiary: Color(0xFF006874),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF97F0FF),
  onTertiaryContainer: Color(0xFF001F24),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFBFDFA),
  onBackground: Color(0xFF191C1B),
  surface: Color(0xFFFBFDFA),
  onSurface: Color(0xFF191C1B),
  surfaceVariant: Color(0xFFDBE5E0),
  onSurfaceVariant: Color(0xFF3F4945),
  outline: Color(0xFF6F7975),
  onInverseSurface: Color(0xFFEFF1EE),
  inverseSurface: Color(0xFF2E312F),
  inversePrimary: Color(0xFF5DDBBC),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006B58),
  outlineVariant: Color(0xFFBFC9C4),
  scrim: Color(0xFF000000),
);


final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme
);


const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF5DDBBC),
  onPrimary: Color(0xFF00382C),
  primaryContainer: Color(0xFF005141),
  onPrimaryContainer: Color(0xFF7CF8D7),
  secondary: Color(0xFF02231C),
  onSecondary: Color(0xFF00363D),
  secondaryContainer: Color(0xFF004F58),
  onSecondaryContainer: Color(0xFFDEEDEE),
  tertiary: Color(0xFFB0D5DB),
  onTertiary: Color(0xFF00363D),
  tertiaryContainer: Color(0xFF004F58),
  onTertiaryContainer: Color(0xFFD3E8EF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C1B),
  onBackground: Color(0xFF4FEE00),
  surface: Color(0xFF191C1B),
  onSurface: Color(0xFFE1E3E0),
  surfaceVariant: Color(0xFF3F4945),
  onSurfaceVariant: Color(0xFFBFC9C4),
  outline: Color(0xFF89938E),
  onInverseSurface: Color(0xFF191C1B),
  inverseSurface: Color(0xFFE1E3E0),
  inversePrimary: Color(0xFF006B58),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF5DDBBC),
  outlineVariant: Color(0xFF3F4945),
  scrim: Color(0xFF000000),
);



final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme
);