import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/calc_controller.dart';
import 'widgets/calc_display.dart';
import '../../../shared/widgets/calc_button.dart';

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CalcController>(
        builder: (context, controller, child) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity!;
              if (velocity.abs() > 500) {
                velocity > 0
                    ? controller.previousDomain()
                    : controller.nextDomain();
              }
            },
            onLongPress: () => controller.constantsMenu(), // π e menu
            child: Column(
              children: [
                // DISPLAY
                Expanded(flex: 3, child: CalcDisplay(controller)),

                // MAIN DIGIT PAD (4x5)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        // 7 8 9 ÷
                        CalcButton(
                          label: '7',
                          onTap: () => controller.digit('7'),
                        ),
                        CalcButton(
                          label: '8',
                          onTap: () => controller.digit('8'),
                        ),
                        CalcButton(
                          label: '9',
                          onTap: () => controller.digit('9'),
                        ),
                        CalcButton(
                          label: '÷',
                          color: Colors.orange,
                          onTap: () => controller.operation('÷'),
                        ),

                        // 4 5 6 ×
                        CalcButton(
                          label: '4',
                          onTap: () => controller.digit('4'),
                        ),
                        CalcButton(
                          label: '5',
                          onTap: () => controller.digit('5'),
                        ),
                        CalcButton(
                          label: '6',
                          onTap: () => controller.digit('6'),
                        ),
                        CalcButton(
                          label: '×',
                          color: Colors.orange,
                          onTap: () => controller.operation('×'),
                        ),

                        // 1 2 3 −
                        CalcButton(
                          label: '1',
                          onTap: () => controller.digit('1'),
                        ),
                        CalcButton(
                          label: '2',
                          onTap: () => controller.digit('2'),
                        ),
                        CalcButton(
                          label: '3',
                          onTap: () => controller.digit('3'),
                        ),
                        CalcButton(
                          label: '−',
                          color: Colors.orange,
                          onTap: () => controller.operation('−'),
                        ),

                        // 0 . ENTER +
                        CalcButton(
                          label: '0',
                          flex: 2,
                          onTap: () => controller.digit('0'),
                        ),
                        CalcButton(
                          label: '.',
                          onTap: () => controller.decimalPoint(),
                        ),
                        CalcButton(
                          label: '⏎',
                          color: Colors.green.shade600,
                          onTap: controller.enter,
                          fontSize: 20,
                        ),
                        CalcButton(
                          label: '+',
                          color: Colors.orange,
                          onTap: () => controller.operation('+'),
                        ),

                        // STACK + DOMAIN
                        CalcButton(
                          label: 'R↓',
                          color: Colors.blue.shade600,
                          onTap: controller.rollDown,
                        ),
                        CalcButton(
                          label: 'DUP',
                          color: Colors.blue.shade500,
                          onTap: controller.dup,
                        ),
                        CalcButton(
                          label: 'SWP',
                          color: Colors.blue.shade500,
                          onTap: controller.swap,
                        ),
                        CalcButton(
                          label: controller.currentDomain.shortLabel,
                          color: Colors.purple,
                          onTap: controller.cycleDomain,
                        ),

                        // CONTROL
                        CalcButton(
                          label: 'CLR',
                          color: Colors.red.shade600,
                          onTap: controller.clearAll,
                        ),
                        CalcButton(
                          label: '⌫',
                          color: Colors.red.shade400,
                          onTap: controller.backspace,
                        ),
                        CalcButton(
                          label: 'π',
                          color: Colors.indigo,
                          onTap: () => controller.constant('pi'),
                        ),
                        CalcButton(
                          label: 'e',
                          color: Colors.indigo,
                          onTap: () => controller.constant('e'),
                        ),
                      ],
                    ),
                  ),
                ),

                // DOMAIN OPERATIONS (Dynamic 2x4 grid)
                if (controller.currentOperations.isNotEmpty)
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      children: controller.currentOperations
                          .take(8)
                          .map(
                            (op) => SizedBox(
                              height: 28,
                              child: CalcButton(
                                label: op.label,
                                fontSize: 12,
                                onTap: () => controller.executeDomainOp(op),
                              ),
                            ),
                          )
                          .toList(),
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
