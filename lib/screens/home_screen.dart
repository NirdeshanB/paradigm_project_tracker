import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'activity_feed_screen.dart';
import 'settings_screen.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  StreamSubscription? _projectsSubscription;
  Timer? _periodicCheckTimer;
  List<Project> _cachedProjects = [];
  final Set<String> _shownAlertKeys = {};
  bool _isAlarmShowing = false;

  static const String _currentVersion = AppTheme.appVersion;
  StreamSubscription? _updateSubscription;

  final List<Widget> _views = const [
    DashboardScreen(),
    ActivityFeedScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startReminderCheck();
    _checkForUpdates();
  }

  @override
  void dispose() {
    _projectsSubscription?.cancel();
    _updateSubscription?.cancel();
    _periodicCheckTimer?.cancel();
    FlutterRingtonePlayer().stop();
    super.dispose();
  }

  void _startReminderCheck() {
    // 1. Listen to real-time project updates from Firestore
    _projectsSubscription = ProjectService().getActiveProjectsStream().listen((projects) {
      if (mounted) {
        setState(() {
          _cachedProjects = projects;
        });
        _checkReminders();
      }
    });

    // 2. Run a periodic check timer every 10 seconds to compare with wall-clock time
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _checkReminders();
      }
    });
  }

  void _checkReminders() {
    if (_isAlarmShowing) return; // Prevent multiple concurrent alarm alerts!

    final now = DateTime.now();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final volume = themeProvider.alarmVolume;

    for (final project in _cachedProjects) {
      if (project.reminderAt == null) continue;

      // Only trigger alarm if project is assigned to the currently logged in user
      if (project.assignedToId.isNotEmpty && project.assignedToId != currentUserId) {
        continue;
      }

      final dueTime = project.reminderAt!;
      final diff = dueTime.difference(now);
      bool isDue = false;

      // Trigger if reminder is due (within 5 minutes in the future, or already passed)
      if (dueTime.isBefore(now) || (diff.inMinutes >= 0 && diff.inMinutes <= 5)) {
        isDue = true;
      }

      // Skip if reminder has a future snooze time set
      if (project.reminderSnoozedUntil != null && project.reminderSnoozedUntil!.isAfter(now)) {
        isDue = false;
      }

      if (isDue) {
        // Unique alert key combining project, reminder timestamp, and snooze timestamp
        final alertKey = '${project.id}_${project.reminderAt!.millisecondsSinceEpoch}_${project.reminderSnoozedUntil?.millisecondsSinceEpoch ?? 0}';
        
        if (!_shownAlertKeys.contains(alertKey)) {
          _shownAlertKeys.add(alertKey);
          _isAlarmShowing = true;

          // Start playing loud ringtone alert with volume configuration
          try {
            FlutterRingtonePlayer().playAlarm(looping: true, volume: volume);
          } catch (_) {
            try {
              FlutterRingtonePlayer().playNotification(volume: volume);
            } catch (_) {}
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAlarmOverlay(project);
          });

          // Break early so only one alert is shown at a time
          break;
        }
      }
    }
  }

  void _showAlarmOverlay(Project project) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Reminder Alert',
      barrierColor: Colors.black.withValues(alpha: 0.8), // Dark blurred background
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent dismissing with back key
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing bell icon
                      _PulsingBellIcon(),

                      const SizedBox(height: 36),

                      Text(
                        'REMINDER ALERT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.projectName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.company,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 36),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              project.nextAction.isEmpty ? 'Scheduled Follow-up' : project.nextAction,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  project.contactNumber,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 56),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                FlutterRingtonePlayer().stop();
                                if (mounted) {
                                  setState(() {
                                    _isAlarmShowing = false;
                                  });
                                }
                                Navigator.pop(context);
                                await ProjectService().snoozeReminder(project, 10);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Reminder snoozed for 10 minutes')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Snooze (10m)',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                FlutterRingtonePlayer().stop();
                                if (mounted) {
                                  setState(() {
                                    _isAlarmShowing = false;
                                  });
                                }
                                Navigator.pop(context);
                                await ProjectService().completeReminder(project);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Action marked as completed!')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Complete',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          FlutterRingtonePlayer().stop();
                          if (mounted) {
                            setState(() {
                              _isAlarmShowing = false;
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Dismiss Alert',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _syncLocalVersionConfig() async {
    // Only synchronize if running in Debug mode (during local development)
    if (!kDebugMode) return;

    try {
      final jsonStr = await rootBundle.loadString('assets/config/version_control.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      final latest = data['latestVersion'] as String? ?? '1.0.0';
      final downloadUrl = data['downloadUrl'] as String? ?? '';
      final features = List<String>.from(data['features'] ?? []);
      final isForceUpdate = data['isForceUpdate'] as bool? ?? false;

      // Update Firestore config document automatically
      await FirebaseFirestore.instance
          .collection('config')
          .doc('appVersion')
          .set({
        'latestVersion': latest,
        'downloadUrl': downloadUrl,
        'features': features,
        'isForceUpdate': isForceUpdate,
      });

      debugPrint('Sync Alert: Local version_control.json synchronized to Firestore appVersion document.');
    } catch (e) {
      debugPrint('Sync Error: Failed to auto-sync local version configuration: $e');
    }
  }

  void _checkForUpdates() {
    _syncLocalVersionConfig();
    _updateSubscription = FirebaseFirestore.instance
        .collection('config')
        .doc('appVersion')
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;
      final data = snapshot.data()!;
      final latest = data['latestVersion'] as String? ?? '1.0.0';
      final downloadUrl = data['downloadUrl'] as String? ?? '';
      final features = List<String>.from(data['features'] ?? []);
      final isForceUpdate = data['isForceUpdate'] as bool? ?? false;

      if (latest != _currentVersion) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog(latest, downloadUrl, features, isForceUpdate);
          });
        }
      }
    });
  }

  void _showUpdateDialog(String latest, String downloadUrl, List<String> features, bool isForceUpdate) {
    showGeneralDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      barrierLabel: 'App Update Available',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return WillPopScope(
          onWillPop: () async => !isForceUpdate,
          child: AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Text(
                  '🚀 ',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  'Update Available',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineMedium?.color,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A newer version (v$latest) of Project Tracker is available. You are running v$_currentVersion.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                if (features.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "What's New:",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...features.map((feat) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                feat,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
            actions: [
              if (!isForceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Later',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  if (downloadUrl.isNotEmpty) {
                    final uri = Uri.parse(downloadUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Update Now',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PulsingBellIcon extends StatefulWidget {
  @override
  State<_PulsingBellIcon> createState() => _PulsingBellIconState();
}

class _PulsingBellIconState extends State<_PulsingBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.notifications_active_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}
