import 'package:flutter/material.dart';


import '../models/activity.dart';
import '../models/user.dart' as app_user;
import '../theme/app_theme.dart';
import '../widgets/avatar_circle.dart';
import '../services/project_service.dart';
import '../services/auth_service.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final _projectService = ProjectService();

  Map<String, List<Activity>> _groupActivitiesList(List<Activity> activitiesList) {
    final map = <String, List<Activity>>{};

    for (final activity in activitiesList) {
      final key = _groupKey(activity.timestamp);
      map.putIfAbsent(key, () => []).add(activity);
    }

    return map;
  }

  String _groupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<app_user.User>>(
      stream: AuthService().getActiveTeamMembersStream(),
      builder: (context, teamSnapshot) {
        final team = teamSnapshot.data ?? [];

        return StreamBuilder<List<Activity>>(
          stream: _projectService.getGlobalActivitiesStream(),
          builder: (context, activitiesSnapshot) {
            final activities = activitiesSnapshot.data ?? [];
            final grouped = _groupActivitiesList(activities);

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activity Feed',
                              style: TextStyle(fontFamily: 'Outfit', 
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Everything your team has been up to',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Team summary
                    if (team.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Row(
                            children: team.map((user) {
                              final count = activities
                                  .where((a) => a.performedById == user.id)
                                  .length;

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: isDark ? Border.all(color: theme.dividerColor) : null,
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    children: [
                                      AvatarCircle.team(
                                        initial: user.initial,
                                        colorHex: user.avatarColor ?? '#4F46E5',
                                        size: 36,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$count',
                                        style: TextStyle(fontFamily: 'Outfit', 
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.name.split(' ').first,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],

                    // Activity groups
                    ...grouped.entries.expand((entry) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        ...entry.value.map((activity) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: _ActivityCard(activity: activity),
                            ),
                          );
                        }),
                      ];
                    }),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: theme.dividerColor) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarCircle(
            initial: activity.performedByInitial,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity.performedByName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      activity.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.icon}  ${activity.title}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyLarge?.color,
                    height: 1.35,
                  ),
                ),
                if (activity.description != null && activity.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
