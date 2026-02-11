import 'package:flutter/material.dart';

class CalcButton extends StatefulWidget {
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
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: () => _controller.reverse(),
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? Colors.grey.shade900).withOpacity(
                      0.4,
                    ),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
