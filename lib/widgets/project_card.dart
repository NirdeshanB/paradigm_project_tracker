import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/project.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import 'days_since_pill.dart';
import 'priority_flag.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onMarkContacted;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onMarkContacted,
  });

  Future<void> _launchCall() async {
    final uri = Uri(scheme: 'tel', path: project.contactNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final phone = project.contactNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: isDark ? Border.all(color: theme.dividerColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Name + Status ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.projectName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${project.company}${project.contactName.isNotEmpty ? " • ${project.contactName}" : ""}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: project.status),
              ],
            ),

            const SizedBox(height: 10),

            // ── Phone + Days Since ──
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: 13, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  project.contactNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                DaysSincePill(days: project.daysSinceContact),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 12),

            // ── Assigned + Priority + Value ──
            Row(
              children: [
                // Avatar
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    project.assignedToInitial,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  project.assignedToName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                PriorityFlag(priority: project.priority),
                const SizedBox(width: 12),
                Text(
                  project.formattedValue,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Next Action ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded,
                      size: 14, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      project.nextAction,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.reminderAt != null)
                    Text(
                      _formatReminder(project.reminderAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Quick Actions ──
            Row(
              children: [
                _QuickActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  color: AppTheme.success,
                  onTap: _launchCall,
                ),
                const SizedBox(width: 8),
                _QuickActionButton(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: _launchWhatsApp,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Contacted',
                    color: AppTheme.primaryLight,
                    onTap: onMarkContacted,
                    expanded: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatReminder(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (target == today) return 'Today, $time';
    if (target == today.add(const Duration(days: 1))) return 'Tomorrow, $time';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, $time';
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool expanded;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: isDark ? Border.all(color: theme.dividerColor) : null,
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
