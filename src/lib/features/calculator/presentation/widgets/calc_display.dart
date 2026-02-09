import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../application/calculator_controller.dart';

class CalcDisplay extends StatelessWidget {
  final CalcController controller;

  const CalcDisplay(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // DOMAIN LABEL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.currentDomain.shortLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const Spacer(),

          // MAIN DISPLAY (X register)
          if (controller.inputBuffer.isNotEmpty)
            Text(
              _formatIndian(controller.inputBuffer),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade300,
                height: 1.1,
              ),
              textAlign: TextAlign.end,
            ),

          // STACK X (primary)
          Text(
            _formatStackItem(controller.stack.isNotEmpty ? controller.stack.last : CalcNumber.zero()),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.end,
          ),

          const SizedBox(height: 8),

          // STACK PREVIEW (Y Z T)
          if (controller.stack.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: controller.stack.reversed.take(4).skip(1).map((item) =>
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        _formatStackItem(item, compact: true),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    )
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatIndian(String input) {
    try {
      final num = double.parse(input);
      if (num == 0) return '0';

      // Indian lakh/crore (en_IN)
      final format = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '',
        decimalDigits: input.contains('.') ? input.split('.').last.length : 0,
      );
      return format.format(num).replaceAll('₹', '').trim();
    } catch (e) {
      return input;
    }
  }

  String _formatStackItem(CalcNumber item, {bool compact = false}) {
    try {
      final value = item.value.toDouble();
      if (value == 0) return '0';

      if (compact && value.abs() > 1000) {
        return NumberFormat.compact(locale: 'en_IN').format(value);
      }

      final format = NumberFormat.decimalPattern('en_IN');
      return format.format(value);
    } catch (e) {
      return item.toString();
    }
  }
}
