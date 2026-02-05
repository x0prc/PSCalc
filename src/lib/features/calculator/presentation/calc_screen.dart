import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/calc_controller.dart';
import 'widgets/calc_display.dart';
import 'widgets/calc_button.dart';

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CalculatorController>(
        builder: (context, controller, child) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 500) {
                controller.previousDomain(); // Swipe RIGHT ←
              } else if (details.primaryVelocity! < -500) {
                controller.nextDomain(); // Swipe LEFT →
              }
            },
            child: Column(
              children: [
                // DISPLAY + DOMAIN INFO
                Expanded(flex: 3, child: CalcDisplay(controller)),

                // MAIN BUTTON PAD
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        // ROW 1: 7 8 9 ÷
                        CalcButton(label: '7', onTap: () => controller.digit('7')),
                        CalcButton(label: '8', onTap: () => controller.digit('8')),
                        CalcButton(label: '9', onTap: () => controller.digit('9')),
                        CalcButton(label: '÷', color: Colors.orange, onTap: () => controller.operation('÷')),

                        // ROW 2: 4 5 6 ×
                        CalcButton(label: '4', onTap: () => controller.digit('4')),
                        CalcButton(label: '5', onTap: () => controller.digit('5')),
                        CalcButton(label: '6', onTap: () => controller.digit('6')),
                        CalcButton(label: '×', color: Colors.orange, onTap: () => controller.operation('×')),

                        // ROW 3: 1 2 3 −
                        CalcButton(label: '1', onTap: () => controller.digit('1')),
                        CalcButton(label: '2', onTap: () => controller.digit('2')),
                        CalcButton(label: '3', onTap: () => controller.digit('3')),
                        CalcButton(label: '−', color: Colors.orange, onTap: () => controller.operation('−')),

                        // ROW 4: 0 . ENTER +
                        CalcButton(label: '0', flex: 2, onTap: () => controller.digit('0')),
                        CalcButton(label: '.', onTap: () => controller.decimalPoint()),
                        CalcButton(
                          label: '⏎',
                          color: Colors.green.shade600,
                          onTap: controller.enter,
                          fontSize: 20,
                        ),
                        CalcButton(label: '+', color: Colors.orange, onTap: () => controller.operation('+')),

                        // ROW 5: CLR ← DOMAIN
                        CalcButton(label: 'CLR', color: Colors.red.shade600, onTap: controller.clearAll),
                        CalcButton(label: '⌫', color: Colors.red.shade400, onTap: controller.backspace),
                        CalcButton(
                          label: controller.currentDomain.shortLabel,
                          color: Colors.purple.shade600,
                          onTap: controller.cycleDomain,
                          fontSize: 18,
                        ),
                        CalcButton(
                          label: '≡', // Menu/Hist
                          color: Colors.blueGrey,
                          onTap: () => controller.toggleHistory(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
