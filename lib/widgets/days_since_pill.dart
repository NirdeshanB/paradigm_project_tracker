import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DaysSincePill extends StatelessWidget {
  final int days;

  const DaysSincePill({
    super.key,
    required this.days,
  });

  bool get _isOverdue => days > 7;

  String get _label {
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '${days}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _isOverdue ? AppTheme.danger : AppTheme.success;
    final backgroundColor = _isOverdue ? AppTheme.dangerBg : AppTheme.successBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isOverdue) ...[
            Icon(
              Icons.warning_amber_rounded,
              size: 11,
              color: color,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'monospace', // close to JetBrains Mono look
            ),
          ),
        ],
      ),
    );
  }
}
