import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/calc_controller.dart';
import 'widgets/calc_display.dart';
import 'widgets/calc_button.dart';

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CalcController>(
        builder: (context, controller, child) {
          return SafeArea(
            child: Column(
              children: [
                // DISPLAY (25% height)
                Expanded(flex: 3, child: CalcDisplay(controller)),

                // MAIN KEYPAD (5x4 = 20 fixed buttons)
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // ROW 1: 7 8 9 ÷
                        _buildButtonRow([
                          _ButtonConfig(
                            label: '7',
                            onTap: () => controller.digit('7'),
                          ),
                          _ButtonConfig(
                            label: '8',
                            onTap: () => controller.digit('8'),
                          ),
                          _ButtonConfig(
                            label: '9',
                            onTap: () => controller.digit('9'),
                          ),
                          _ButtonConfig(
                            label: '÷',
                            color: Colors.orange,
                            onTap: () => controller.operation('÷'),
                          ),
                        ]),

                        const SizedBox(height: 8),

                        // ROW 2: 4 5 6 ×
                        _buildButtonRow([
                          _ButtonConfig(
                            label: '4',
                            onTap: () => controller.digit('4'),
                          ),
                          _ButtonConfig(
                            label: '5',
                            onTap: () => controller.digit('5'),
                          ),
                          _ButtonConfig(
                            label: '6',
                            onTap: () => controller.digit('6'),
                          ),
                          _ButtonConfig(
                            label: '×',
                            color: Colors.orange,
                            onTap: () => controller.operation('×'),
                          ),
                        ]),

                        const SizedBox(height: 8),

                        // ROW 3: 1 2 3 −
                        _buildButtonRow([
                          _ButtonConfig(
                            label: '1',
                            onTap: () => controller.digit('1'),
                          ),
                          _ButtonConfig(
                            label: '2',
                            onTap: () => controller.digit('2'),
                          ),
                          _ButtonConfig(
                            label: '3',
                            onTap: () => controller.digit('3'),
                          ),
                          _ButtonConfig(
                            label: '−',
                            color: Colors.orange,
                            onTap: () => controller.operation('−'),
                          ),
                        ]),

                        const SizedBox(height: 8),

                        // ROW 4: 0 . ENTER +
                        _buildButtonRow([
                          _ButtonConfig(
                            label: '0',
                            color: Colors.grey.shade700,
                            onTap: () => controller.digit('0'),
                            flex: 2,
                          ),
                          _ButtonConfig(
                            label: '.',
                            color: Colors.grey.shade700,
                            onTap: controller.decimalPoint,
                          ),
                          _ButtonConfig(
                            label: '⏎',
                            color: Colors.green.shade600,
                            onTap: controller.enter,
                            fontSize: 20,
                          ),
                          _ButtonConfig(
                            label: '+',
                            color: Colors.orange,
                            onTap: () => controller.operation('+'),
                          ),
                        ]),

                        const SizedBox(height: 8),

                        // ROW 5: STACK + CONTROL + DOMAIN
                        _buildButtonRow([
                          _ButtonConfig(
                            label: 'R↓',
                            color: Colors.blue.shade700,
                            onTap: controller.rollDown,
                          ),
                          _ButtonConfig(
                            label: 'CLR',
                            color: Colors.red.shade700,
                            onTap: controller.clearAll,
                          ),
                          _ButtonConfig(
                            label: controller.currentDomain.shortLabel,
                            color: Colors.purple.shade700,
                            onTap: controller.cycleDomain,
                          ),
                          _ButtonConfig(
                            label: '≡',
                            color: Colors.grey.shade800,
                            onTap: controller.toggleHistory,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),

                // DOMAIN OPS (scrollable if >8)
                if (controller.currentOperations.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: controller.currentOperations.length,
                      itemBuilder: (context, index) {
                        final op = controller.currentOperations[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CalcButton(
                            label: op.label,
                            size: 70,
                            fontSize: 12,
                            onTap: () => controller.executeDomainOp(op),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonRow(List<_ButtonConfig> configs) {
    return Expanded(
      child: Row(
        children: configs
            .map(
              (config) => Expanded(
                flex: config.flex ?? 1,
                child: CalcButton(
                  label: config.label,
                  color: config.color,
                  fontSize: config.fontSize ?? 24,
                  onTap: config.onTap,
                  onLongPress: config.onLongPress,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ButtonConfig {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? fontSize;
  final int? flex;

  const _ButtonConfig({
    required this.label,
    this.onTap,
    this.color,
    this.onLongPress,
    this.fontSize,
    this.flex,
  });
}
