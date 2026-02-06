import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final int? flex;
  final double? fontSize;

  const CalcButton({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.flex,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize ?? 18, fontWeight: FontWeight.bold),
      ),
    );

    return button;
  }
}
