import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color(0xFFE9E9E9),
    primary: Color.fromARGB(255, 202, 202, 202),
    secondary: Color(0xFF12964A),
    onSurface: Colors.black,
    onSurfaceVariant: Color.fromARGB(133, 17, 17, 17),
    ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212),
    primary: Color(0xFF1E1E1E),
    secondary: Color(0xFF12964A),
    onSurface: Colors.white,
    onSurfaceVariant: Color.fromARGB(133, 226, 226, 226),
  ),
);