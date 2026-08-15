import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/avatar_circle.dart';
import '../models/user.dart' as app_user;
import '../models/project.dart';
import '../models/activity.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';
import 'add_user_screen.dart';
import 'edit_profile_screen.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<app_user.User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Initial and email safety fallbacks
    final initial = user?.initial ?? 'U';
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final role = user?.role ?? 'member';

    // Current preference values
    final notificationsPref = user?.notifications ?? 'All';
    final reminderPref = user?.defaultReminder ?? '10:00 AM';

    // Calculate dynamic timezone
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    final localTimeZone = DateTime.now().timeZoneName;
    final offsetStr = "GMT${hours >= 0 ? '+' : '-'}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
    final timeZoneStr = "Automatic ($offsetStr $localTimeZone)";

    return StreamBuilder<List<app_user.User>>(
      stream: _authService.getActiveTeamMembersStream(),
      builder: (context, teamSnapshot) {
        final team = teamSnapshot.data ?? [];

        return StreamBuilder<List<Project>>(
          stream: _projectService.getActiveProjectsStream(),
          builder: (context, projectsSnapshot) {
            final projectsCount = projectsSnapshot.data?.length ?? 0;

            return StreamBuilder<List<Activity>>(
              stream: _projectService.getGlobalActivitiesStream(),
              builder: (context, activitiesSnapshot) {
                final activitiesCount = activitiesSnapshot.data?.length ?? 0;

                return Scaffold(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  body: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        // Header row with logo aligned right & circular add button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(fontFamily: 'Outfit', 
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (role == 'super_admin') ...[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AddUserScreen(),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [AppTheme.primary, AppTheme.primaryLight],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                ],
                                Image.asset(
                                  isDark
                                      ? 'assets/images/logo_dark.png'
                                      : 'assets/images/logo_grey.png',
                                  width: 80,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () {
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(user: user),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                    : [Colors.white, const Color(0xFFF1F5F9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: isDark ? Border.all(color: theme.dividerColor) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primaryLight, width: 2),
                                  ),
                                  child: AvatarCircle(
                                    initial: initial,
                                    size: 60,
                                    backgroundColor: AppTheme.primary,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(fontFamily: 'Outfit', 
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: theme.textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 14,
                                            color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        role == 'super_admin'
                                            ? 'Super Admin'
                                            : (role == 'admin' ? 'Admin' : 'Member'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryLight,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                        // Privileged Administration Section for super admins
                        if (role == 'super_admin') ...[
                          const SizedBox(height: 28),
                          _sectionLabel('Administration'),
                          _SettingsTile(
                            icon: '👤',
                            title: 'Add New Team Member',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddUserScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: 28),
                        _sectionLabel('Preferences'),

                        _SettingsTile(
                          icon: '◐',
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (v) => themeProvider.toggleTheme(),
                            activeThumbColor: AppTheme.primaryLight,
                          ),
                        ),
                        _SettingsTile(
                          icon: '🔊',
                          title: 'Alarm Volume',
                          trailing: SizedBox(
                            width: 140,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                activeTrackColor: theme.colorScheme.primary,
                                inactiveTrackColor: theme.dividerColor,
                                thumbColor: theme.colorScheme.primary,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              ),
                              child: Slider(
                                value: themeProvider.alarmVolume,
                                min: 0.0,
                                max: 1.0,
                                onChanged: (v) {
                                  themeProvider.setAlarmVolume(v);
                                },
                                onChangeEnd: (v) {
                                  try {
                                    FlutterRingtonePlayer().playNotification(volume: v);
                                  } catch (_) {}
                                },
                              ),
                            ),
                          ),
                        ),
                        _SettingsTile(
                          icon: '🔔',
                          title: 'Notifications',
                          trailing: Text(
                            notificationsPref,
                            style: TextStyle(
                                color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            if (user != null) {
                              final nextVal = notificationsPref == 'All' ? 'Muted' : 'All';
                              _authService.updateUserSettings(
                                uid: user.id,
                                notifications: nextVal,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Notifications set to: $nextVal')),
                              );
                            }
                          },
                        ),
                        _SettingsTile(
                          icon: '⏰',
                          title: 'Default Reminder',
                          trailing: Text(
                            reminderPref,
                            style: TextStyle(
                                color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () async {
                            if (user != null) {
                              // Parse initial hours & minutes from database preference
                              int initHour = 10;
                              int initMinute = 0;
                              try {
                                final cleanTime = reminderPref.replaceAll(RegExp(r'\s+[A-Z]+'), '');
                                final parts = cleanTime.split(':');
                                if (parts.length >= 2) {
                                  initHour = int.parse(parts[0]);
                                  initMinute = int.parse(parts[1]);
                                  if (reminderPref.contains('PM') && initHour < 12) {
                                    initHour += 12;
                                  } else if (reminderPref.contains('AM') && initHour == 12) {
                                    initHour = 0;
                                  }
                                }
                              } catch (_) {}

                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: initHour, minute: initMinute),
                              );
                              if (picked != null) {
                                final hourStr = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                                final minuteStr = picked.minute.toString().padLeft(2, '0');
                                final periodStr = picked.period == DayPeriod.am ? 'AM' : 'PM';
                                final formatted = "$hourStr:$minuteStr $periodStr";
                                _authService.updateUserSettings(
                                  uid: user.id,
                                  defaultReminder: formatted,
                                );
                              }
                            }
                          },
                        ),
                        _SettingsTile(
                          icon: '🌍',
                          title: 'Time Zone',
                          trailing: Text(
                            timeZoneStr,
                            style: TextStyle(
                                color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Time zone is locked to device automatic timezone: $localTimeZone')),
                            );
                          },
                        ),

                        if (team.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _sectionLabel('Team'),
                          ...team.map((u) {
                            return _TeamTile(
                              initial: u.initial,
                              name: u.name,
                              role: u.role == 'super_admin'
                                  ? 'Super Admin'
                                  : (u.role == 'admin' ? 'Admin' : 'Member'),
                              isYou: u.id == (user?.id ?? ''),
                              colorHex: u.avatarColor,
                            );
                          }),
                        ],

                        const SizedBox(height: 28),
                        _sectionLabel('Data'),

                        _SettingsTile(
                          icon: '📥',
                          title: 'Export to CSV',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Export started…')),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: '📤',
                          title: 'Import Projects',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: '🔗',
                          title: 'Integrations',
                          trailing: Text(
                            '0 connected',
                            style: TextStyle(
                                color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                fontSize: 13),
                          ),
                          onTap: () {},
                        ),

                        const SizedBox(height: 28),
                        _sectionLabel('Workspace'),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark ? Border.all(color: theme.dividerColor) : null,
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              _WorkspaceStat(
                                  value: '$projectsCount',
                                  label: 'Projects'),
                              _WorkspaceStat(
                                  value: '${team.length}',
                                  label: 'Team Size'),
                              _WorkspaceStat(
                                  value: '$activitiesCount',
                                  label: 'Activities'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              _authService.signOut();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger,
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Paradigm Projects v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                            ),
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
      },
    );
  }

  Widget _sectionLabel(String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: theme.brightness == Brightness.dark ? Border.all(color: theme.dividerColor) : null,
        boxShadow: theme.brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Text(icon, style: const TextStyle(fontSize: 18)),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color),
        ),
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF64748B)
                    : AppTheme.textMuted,
                size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final String initial;
  final String name;
  final String role;
  final bool isYou;
  final String? colorHex;

  const _TeamTile({
    required this.initial,
    required this.name,
    required this.role,
    this.isYou = false,
    this.colorHex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: theme.dividerColor) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          AvatarCircle.team(initial: initial, colorHex: colorHex, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceStat extends StatelessWidget {
  final String value;
  final String label;

  const _WorkspaceStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontFamily: 'Outfit', 
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF64748B)
                  : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
