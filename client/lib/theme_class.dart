import 'package:flutter/material.dart';

class ThemeClass{
 
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(secondary: Colors.indigoAccent),
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,  
    )
  );
 
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.indigo,
    
    colorScheme: const ColorScheme.dark(secondary: Colors.indigoAccent),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
      )
  );
}
