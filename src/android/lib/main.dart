import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/calculator/application/calc_controller.dart';
import 'features/calculator/domain/basic_domain.dart';
import 'features/calculator/presentation/calc_screen.dart';

void main() {
  runApp(const PSCalcApp());
}

class PSCalcApp extends StatelessWidget {
  const PSCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalcController(allDomains: [BasicDomain()]),
      child: MaterialApp(
        title: 'PSCalc',
        theme: ThemeData.dark(useMaterial3: true),
        home: const CalcScreen(),
      ),
    );
  }
}
