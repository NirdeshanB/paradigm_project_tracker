import 'package:flutter/material.dart';


import '../models/project.dart';
import '../theme/app_theme.dart';
import '../services/project_service.dart';

class SnoozeModal extends StatelessWidget {
  final Project project;

  const SnoozeModal({
    super.key,
    required this.project,
  });

  void _snooze(BuildContext context, Duration duration, String label) {
    final newTime = DateTime.now().add(duration);
    _snoozeToDate(context, newTime, label);
  }

  void _snoozeToDate(BuildContext context, DateTime date, String label) {
    ProjectService().snoozeProject(
      projectId: project.id,
      reminderAt: date,
      reminderSnoozedUntil: date,
    ).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Snoozed to $label')),
        );
        Navigator.pop(context, true);
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error snoozing: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tomorrow10 = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + 1,
      10,
    );

    final tomorrow14 = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + 1,
      14,
    );

    final nextMonday = DateTime.now().add(
      Duration(days: (8 - DateTime.now().weekday) % 7),
    );
    final nextMonday9 = DateTime(
      nextMonday.year,
      nextMonday.month,
      nextMonday.day,
      9,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Snooze Reminder',
            style: TextStyle(fontFamily: 'Outfit', 
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.projectName,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          _SnoozeOption(
            label: '1 hour',
            onTap: () =>
                _snooze(context, const Duration(hours: 1), '1 hour from now'),
          ),
          _SnoozeOption(
            label: '3 hours',
            onTap: () =>
                _snooze(context, const Duration(hours: 3), '3 hours from now'),
          ),
          _SnoozeOption(
            label: 'Tomorrow, 10:00 AM',
            onTap: () =>
                _snoozeToDate(context, tomorrow10, 'Tomorrow 10:00 AM'),
          ),
          _SnoozeOption(
            label: 'Tomorrow, 2:00 PM',
            onTap: () => _snoozeToDate(context, tomorrow14, 'Tomorrow 2:00 PM'),
          ),
          _SnoozeOption(
            label: 'In 2 days',
            onTap: () => _snooze(context, const Duration(days: 2), 'in 2 days'),
          ),
          _SnoozeOption(
            label: 'Next Monday, 9:00 AM',
            onTap: () =>
                _snoozeToDate(context, nextMonday9, 'Next Monday 9:00 AM'),
          ),
          _SnoozeOption(
            label: 'Custom date & time…',
            isCustom: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date == null || !context.mounted) return;

              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 10, minute: 0),
              );
              if (time == null || !context.mounted) return;

              final custom = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );

              _snoozeToDate(
                context,
                custom,
                '${date.day}/${date.month} ${time.format(context)}',
              );
            },
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnoozeOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isCustom;

  const _SnoozeOption({
    required this.label,
    required this.onTap,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final optionBgColor = isCustom
        ? (isDark ? const Color(0xFF0F172A) : AppTheme.background)
        : null;
    final contentColor = isCustom
        ? AppTheme.primaryLight
        : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: optionBgColor,
        ),
        child: Row(
          children: [
            Icon(
              isCustom ? Icons.calendar_today_rounded : Icons.schedule_rounded,
              size: 18,
              color: contentColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isCustom ? FontWeight.bold : FontWeight.w500,
                color: isCustom ? AppTheme.primaryLight : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
