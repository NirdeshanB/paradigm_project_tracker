import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color get _color {
    switch (status.toLowerCase()) {
      case 'active':
      case 'won':
        return AppTheme.success;
      case 'proposal':
        return AppTheme.primary;
      case 'new':
        return AppTheme.info;
      case 'on hold':
        return const Color(0xFFC2410C);
      case 'cancelled':
      case 'unreachable':
        return AppTheme.textMuted;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'active':
      case 'won':
        return AppTheme.successBg;
      case 'proposal':
        return const Color(0xFFEEF2FF);
      case 'new':
        return AppTheme.infoBg;
      case 'on hold':
        return AppTheme.warningBg;
      default:
        return AppTheme.surfaceSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
