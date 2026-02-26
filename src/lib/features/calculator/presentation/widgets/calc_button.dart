import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double fontSize;
  final double size;

  const CalcButton({
    super.key,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.color,
    this.fontSize = 24,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.grey.shade700;
    final topColor = Color.lerp(baseColor, Colors.white, 0.15)!;
    final bottomColor = Color.lerp(baseColor, Colors.black, 0.15)!;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, baseColor, bottomColor],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            onLongPress: onLongPress,
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
