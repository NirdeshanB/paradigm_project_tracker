import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/project.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';
import '../services/project_service.dart';
import 'snooze_modal.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _project;
  final _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  Future<void> _launchCall() async {
    final cleanPhone = _project.contactNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    final phone = _project.contactNumber.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$phone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  void _openSnooze(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SnoozeModal(project: _project),
    );
  }

  void _deleteProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${_project.projectName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              _projectService.softDeleteProject(_project.id).then((_) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Project deleted')),
                );
                navigator.pop(); // pop detail screen
              }).catchError((e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error deleting project: $e')),
                );
              });
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProjectScreen(project: _project),
      ),
    );
  }

  void _markContacted() {
    _projectService.markContacted(_project).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as contacted')),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking as contacted: $e')),
        );
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'On Hold':
        return const Color(0xFFF97316);
      case 'Active':
        return const Color(0xFF4F46E5);
      case 'New':
        return const Color(0xFF0EA5E9);
      case 'Proposal':
        return const Color(0xFF7C3AED);
      case 'Won':
        return const Color(0xFF10B981);
      case 'Lost':
      case 'Cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getStatusBgColor(String status, bool isDark) {
    switch (status) {
      case 'On Hold':
        return isDark ? const Color(0xFF3E2B1E) : const Color(0xFFFFF7ED);
      case 'Active':
        return isDark ? const Color(0xFF2C285C) : const Color(0xFFEEF0FF);
      case 'New':
        return isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F5FE);
      case 'Proposal':
        return isDark ? const Color(0xFF37225F) : const Color(0xFFF5F3FF);
      case 'Won':
        return isDark ? const Color(0xFF1B3E2F) : const Color(0xFFECFDF5);
      case 'Lost':
      case 'Cancelled':
        return isDark ? const Color(0xFF4C1C1C) : const Color(0xFFFFE4E6);
      default:
        return AppTheme.borderLight;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF97316);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatReminderTime(DateTime? date) {
    if (date == null) return 'No reminder set';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat('h:mm a').format(date);

    if (target == today) return 'Today, $timeStr';
    if (target == tomorrow) return 'Tomorrow, $timeStr';

    final diff = date.difference(now).inDays;
    if (diff > 0 && diff < 7) {
      return '${DateFormat('E').format(date)}, $timeStr';
    }

    return '${DateFormat('yMMMd').format(date)}, $timeStr';
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final infoAccentColor = theme.colorScheme.primaryContainer;
    final nextActionBg = theme.colorScheme.primaryContainer;
    final nextActionBorder = theme.colorScheme.primary.withValues(alpha: 0.3);

    return StreamBuilder<Project?>(
      stream: _projectService.getProjectStream(widget.project.id),
      initialData: widget.project,
      builder: (context, projectSnapshot) {
        final project = projectSnapshot.data ?? _project;
        _project = project;

        return StreamBuilder<List<Activity>>(
          stream: _projectService.getProjectActivitiesStream(project.id),
          builder: (context, activitiesSnapshot) {
            final projectActivities = activitiesSnapshot.data ?? [];

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    // Custom Back Navigation Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded,
                                    size: 14,
                                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'All Projects',
                                  style: TextStyle(fontFamily: 'Inter', 
                                    fontSize: 14,
                                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _deleteProject(context),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: () => _editProject(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primaryLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Edit',
                                      style: TextStyle(fontFamily: 'Inter', 
                                        fontSize: 14,
                                        color: AppTheme.primaryLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.projectName,
                                          style: TextStyle(fontFamily: 'Outfit', 
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.headlineMedium?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          project.company,
                                          style: TextStyle(fontFamily: 'Inter', 
                                            fontSize: 14,
                                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusBgColor(project.status, isDark),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _getStatusColor(project.status),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              project.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(project.status),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.flag_rounded,
                                            color: _getPriorityColor(project.priority),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.priority == 'Medium' ? 'Med' : project.priority,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _getPriorityColor(project.priority),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Badges Row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF4C1C1C) : const Color(0xFFFFF1F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isDark ? const Color(0xFF8C2C2C) : const Color(0xFFFFD5D5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${project.daysSinceContact}d ago',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: infoAccentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      project.formattedValue,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Card 1: CONTACT & ASSIGNED TO
                            _detailCard(
                              children: [
                                _cardSectionHeader('CONTACT'),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppTheme.primary,
                                      child: Text(
                                        project.contactName.isNotEmpty ? project.contactName[0] : '?',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.contactName,
                                          style: TextStyle(fontFamily: 'Inter', 
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          project.contactNumber,
                                          style: TextStyle(fontFamily: 'Inter', 
                                            fontSize: 13,
                                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _cardSectionHeader('ASSIGNED TO'),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppTheme.primaryLight,
                                      child: Text(
                                        project.assignedToInitial,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      project.assignedToName,
                                      style: TextStyle(fontFamily: 'Inter', 
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Card 2: NEXT ACTION
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: nextActionBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: nextActionBorder, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NEXT ACTION',
                                    style: TextStyle(fontFamily: 'Inter', 
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryLight,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    project.nextAction,
                                    style: TextStyle(fontFamily: 'Inter', 
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primaryLight),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatReminderTime(project.reminderAt),
                                        style: TextStyle(fontFamily: 'Inter', 
                                          fontSize: 13,
                                          color: AppTheme.primaryLight,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      OutlinedButton(
                                        onPressed: () => _openSnooze(context),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: theme.cardColor,
                                          foregroundColor: AppTheme.primaryLight,
                                          side: const BorderSide(color: AppTheme.primaryLight),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Snooze',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Tags Wrap
                            if (project.tags.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: project.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: infoAccentColor.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: theme.dividerColor),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(fontFamily: 'Inter', 
                                          fontSize: 11,
                                          color: AppTheme.primaryLight,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],

                            // Card 3: NOTES
                            _detailCard(
                              children: [
                                _cardSectionHeader('NOTES'),
                                const SizedBox(height: 10),
                                Text(
                                  project.notes.isEmpty ? 'No notes yet' : project.notes,
                                  style: TextStyle(fontFamily: 'Inter', 
                                    fontSize: 14,
                                    color: project.notes.isEmpty
                                        ? (isDark ? const Color(0xFF64748B) : AppTheme.textMuted)
                                        : theme.textTheme.bodyLarge?.color,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),

                            // Card 4: ACTIVITY LOG
                            _detailCard(
                              children: [
                                _cardSectionHeader('ACTIVITY LOG'),
                                const SizedBox(height: 12),
                                if (projectActivities.isEmpty)
                                  Text(
                                    'No activity logs yet',
                                    style: TextStyle(fontFamily: 'Inter', 
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                    ),
                                  )
                                else
                                  ...projectActivities.map((act) {
                                    final isLast = act == projectActivities.last;
                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: theme.brightness == Brightness.dark
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFFF1F5F9),
                                                child: Text(
                                                  act.performedByInitial,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (!isLast)
                                                Expanded(
                                                  child: Container(
                                                    width: 1.5,
                                                    color: theme.dividerColor,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          act.title,
                                                          style: TextStyle(fontFamily: 'Inter', 
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: theme.textTheme.bodyLarge?.color,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatTimeAgo(act.timestamp),
                                                        style: TextStyle(fontFamily: 'Inter', 
                                                          fontSize: 12,
                                                          color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (act.description != null && act.description!.isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      act.description!,
                                                      style: TextStyle(fontFamily: 'Inter', 
                                                        fontSize: 12,
                                                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'by ${act.performedByName}',
                                                    style: TextStyle(fontFamily: 'Inter', 
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Actions Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(top: BorderSide(color: theme.dividerColor)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _launchCall,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Call',
                                style: TextStyle(fontFamily: 'Inter', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _launchWhatsApp,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'WhatsApp',
                                style: TextStyle(fontFamily: 'Inter', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: _markContacted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryLight,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '✓ Mark Contacted',
                                style: TextStyle(fontFamily: 'Outfit', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailCard({required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: theme.dividerColor, width: 1.5) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _cardSectionHeader(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(fontFamily: 'Inter', 
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: theme.brightness == Brightness.dark ? const Color(0xFF64748B) : AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
