import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvatarCircle extends StatelessWidget {
  final String initial;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final bool showBorder;

  const AvatarCircle({
    super.key,
    required this.initial,
    this.size = 32,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 13,
    this.showBorder = false,
  });

  /// Convenience constructor for team members
  factory AvatarCircle.team({
    required String initial,
    required String? colorHex,
    double size = 32,
  }) {
    Color bg = AppTheme.primary;

    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        final hex = colorHex.replaceFirst('#', '');
        bg = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    return AvatarCircle(
      initial: initial,
      size: size,
      backgroundColor: bg,
      fontSize: size * 0.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primary,
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
