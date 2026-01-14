import 'package:flutter/material.dart';
import '../../../core/engine/{number.dart,rpn_engine.dart,algebraic_engine.dart}';
import '../../../shared/widgets/calc_button.dart';

enum InputMode { algebraic, rpn }

class CalcScreen extends StatefulWidget{
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}