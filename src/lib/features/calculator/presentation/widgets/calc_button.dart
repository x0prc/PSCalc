import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? Colors.grey.shade700;
    final highlightColor = Color.lerp(baseColor, Colors.white, 0.25)!;
    final shadowColor = Color.lerp(baseColor, Colors.black, 0.4)!;
    final deepShadowColor = Color.lerp(baseColor, Colors.black, 0.6)!;

    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                children: [
                  // Deep shadow layer (bottom)
                  Positioned(
                    top: 3,
                    left: 2,
                    right: 2,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: deepShadowColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  // Main button body with beveled effect
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [highlightColor, baseColor, shadowColor],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          // Top highlight
                          BoxShadow(
                            color: highlightColor.withOpacity(0.6),
                            offset: const Offset(0, -1),
                            blurRadius: 2,
                          ),
                          // Side shadows
                          BoxShadow(
                            color: shadowColor.withOpacity(0.5),
                            offset: const Offset(-1, 2),
                            blurRadius: 3,
                          ),
                          BoxShadow(
                            color: shadowColor.withOpacity(0.5),
                            offset: const Offset(1, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.label,
                            style: GoogleFonts.roboto(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pressed state overlay
                  if (_isPressed)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
