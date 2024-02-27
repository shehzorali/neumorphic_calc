import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calculator_screen.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final ThemeMode _currentTheme = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      themeMode: _currentTheme,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}