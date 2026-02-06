import 'package:flutter/material.dart';
import '../../application/calc_controller.dart';

class CalcDisplay extends StatelessWidget {
  final CalcController controller;

  const CalcDisplay(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Domain label
          Text(
            controller.currentDomain.name,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Stack display
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: controller.stack.length,
              itemBuilder: (context, index) {
                final reverseIndex = controller.stack.length - 1 - index;
                final item = controller.stack[reverseIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${reverseIndex + 1}: ${item.value.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Input buffer
          Text(
            controller.inputBuffer.isEmpty ? '0' : controller.inputBuffer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
