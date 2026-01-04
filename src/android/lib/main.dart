import 'package:flutter/material.dart';

void main() {
  runApp(const PSCalcApp());
}

class PSCalcApp extends StatelessWidget {
  const PSCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSCalc',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}
