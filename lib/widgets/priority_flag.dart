import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PriorityFlag extends StatelessWidget {
  final String priority;

  const PriorityFlag({
    super.key,
    required this.priority,
  });

  Color get _color {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.priorityHigh;
      case 'medium':
      case 'med':
        return AppTheme.priorityMedium;
      case 'low':
        return AppTheme.priorityLow;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _label {
    switch (priority.toLowerCase()) {
      case 'medium':
        return 'Med';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.flag_rounded,
          size: 12,
          color: _color,
        ),
        const SizedBox(width: 3),
        Text(
          _label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    );
  }
}
