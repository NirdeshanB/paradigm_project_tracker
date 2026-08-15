import 'package:flutter/material.dart';


import '../theme/app_theme.dart';
import '../services/config_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_user;

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({super.key});

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  final Set<String> _selectedStatuses = {};
  final Set<String> _selectedPriorities = {};
  final Set<String> _selectedAssignees = {};
  String _daysFilter = 'Any';

  void _reset() {
    setState(() {
      _selectedStatuses.clear();
      _selectedPriorities.clear();
      _selectedAssignees.clear();
      _daysFilter = 'Any';
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ConfigService();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

          Row(
            children: [
              Text(
                'Filters',
                style: TextStyle(fontFamily: 'Outfit', 
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.headlineMedium?.color,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _sectionTitle('Status'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: config.statuses.map((status) {
              final selected = _selectedStatuses.contains(status);
              return FilterChip(
                label: Text(status),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
                selectedColor: AppTheme.primaryLight.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.primaryLight,
                labelStyle: TextStyle(
                  color: selected
                      ? AppTheme.primaryLight
                      : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _sectionTitle('Priority'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: config.priorities.map((p) {
              final selected = _selectedPriorities.contains(p);
              return FilterChip(
                label: Text(p),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedPriorities.add(p);
                    } else {
                      _selectedPriorities.remove(p);
                    }
                  });
                },
                selectedColor: AppTheme.primaryLight.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.primaryLight,
                labelStyle: TextStyle(
                  color: selected
                      ? AppTheme.primaryLight
                      : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _sectionTitle('Assigned To'),
          const SizedBox(height: 8),
          StreamBuilder<List<app_user.User>>(
            stream: AuthService().getActiveTeamMembersStream(),
            builder: (context, snapshot) {
              final team = snapshot.data ?? [];
              return Wrap(
                spacing: 8,
                children: team.map((u) {
                  final name = u.name.split(' ').first;
                  final selected = _selectedAssignees.contains(name);
                  return FilterChip(
                    label: Text(name),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedAssignees.add(name);
                        } else {
                          _selectedAssignees.remove(name);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryLight.withValues(alpha: 0.15),
                    checkmarkColor: AppTheme.primaryLight,
                    labelStyle: TextStyle(
                      color: selected
                          ? AppTheme.primaryLight
                          : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),
          _sectionTitle('Days Since Contact'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Any',
              'Today',
              'Last 3 days',
              'Last 7 days',
              'Overdue (>7 days)'
            ].map((option) {
              final selected = _daysFilter == option;
              return ChoiceChip(
                label: Text(option),
                selected: selected,
                onSelected: (_) => setState(() => _daysFilter = option),
                selectedColor: AppTheme.primaryLight.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected
                      ? AppTheme.primaryLight
                      : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Show Results'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}
