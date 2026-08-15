import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/project.dart';
import '../models/user.dart' as app_user;
import '../theme/app_theme.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/project_card.dart';
import '../services/project_service.dart';
import 'create_project_screen.dart';
import 'filters_sheet.dart';
import 'project_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'filtered_projects_screen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _projectService = ProjectService();
  late Stream<List<Project>> _projectsStream;

  @override
  void initState() {
    super.initState();
    _projectsStream = _projectService.getActiveProjectsStream();
  }

  List<Project> _filterProjectsList(List<Project> allProjects) {
    var list = allProjects;

    if (_selectedFilter != 'All') {
      list = list.where((p) => p.assignedToName == _selectedFilter).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) {
        return p.projectName.toLowerCase().contains(query) ||
            p.company.toLowerCase().contains(query) ||
            p.contactName.toLowerCase().contains(query) ||
            p.contactNumber.contains(query);
      }).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<app_user.User?>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic user initials fallback
    final initial = currentUser?.initial ?? 'U';
    final userName = currentUser?.name ?? 'User';

    return StreamBuilder<List<Project>>(
      stream: _projectsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          );
        }

        final allProjects = snapshot.data ?? [];
        final projects = _filterProjectsList(allProjects);

        final overdueCount = allProjects.where((p) => p.isOverdue).length;
        final myAssignedCount = allProjects.where((p) => p.assignedToId == (currentUser?.id ?? '')).length;
        final highPriorityCount = allProjects.where((p) => p.priority == 'High').length;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOOD MORNING',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userName,
                                style: TextStyle(fontFamily: 'Outfit', 
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.headlineMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateProjectScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryLight
                                ],
                              ),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 22),
                          ),
                        ),
                         const SizedBox(width: 10),
                         GestureDetector(
                           onTap: () {
                             final currentUser = Provider.of<app_user.User?>(context, listen: false);
                             if (currentUser != null) {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (_) => EditProfileScreen(user: currentUser),
                                 ),
                               );
                             }
                           },
                           child: AvatarCircle(
                             initial: initial,
                             size: 38,
                             backgroundColor: AppTheme.primary,
                           ),
                         ),
                      ],
                    ),
                  ),
                ),

                // Stats
                const SizedBox(height: 20).sliverBox,
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Overdue follow-ups banner
                      GestureDetector(
                        onTap: () {
                          final overdueProjects = allProjects.where((p) => p.isOverdue).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FilteredProjectsScreen(
                                title: 'Overdue Follow-ups',
                                projects: overdueProjects,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.error_outline_rounded,
                                  color: theme.colorScheme.error,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overdue follow-ups',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onErrorContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${overdueCount == 1 ? "1 contact" : "$overdueCount contacts"} not reached in 7+ days',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$overdueCount',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 3 horizontal mini cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStatCard(
                              icon: Icons.folder_open_outlined,
                              iconColor: theme.colorScheme.onPrimaryContainer,
                              iconBg: theme.colorScheme.primaryContainer,
                              value: '${allProjects.length}',
                              label: 'Total',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FilteredProjectsScreen(
                                      title: 'Total Projects',
                                      projects: allProjects,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMiniStatCard(
                              icon: Icons.person_outline_rounded,
                              iconColor: theme.colorScheme.onSecondaryContainer,
                              iconBg: theme.colorScheme.secondaryContainer,
                              value: '$myAssignedCount',
                              label: 'Mine',
                              onTap: () {
                                final myProjects = allProjects.where((p) => p.assignedToId == (currentUser?.id ?? '')).toList();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FilteredProjectsScreen(
                                      title: 'My Projects',
                                      projects: myProjects,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMiniStatCard(
                              icon: Icons.flag_outlined,
                              iconColor: theme.colorScheme.onTertiaryContainer,
                              iconBg: theme.colorScheme.tertiaryContainer,
                              value: '$highPriorityCount',
                              label: 'High pri',
                              onTap: () {
                                final highProjects = allProjects.where((p) => p.priority == 'High').toList();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FilteredProjectsScreen(
                                      title: 'High Priority Projects',
                                      projects: highProjects,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),

                // Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
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
                      child: TextField(
                        key: const ValueKey('search_field'),
                        focusNode: _searchFocusNode,
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: 'Search projects, contacts…',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: StreamBuilder<List<app_user.User>>(
                    stream: AuthService().getActiveTeamMembersStream(),
                    builder: (context, snapshot) {
                      final team = snapshot.data ?? [];
                      final names = ['All'] + team.map((u) => u.name.split(' ').first).toList();

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Filters',
                              icon: Icons.tune_rounded,
                              isSelected: false,
                              onTap: _openFilters,
                            ),
                            const SizedBox(width: 8),
                            ...names.map((name) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: name,
                                  isSelected: _selectedFilter == name,
                                  onTap: () =>
                                      setState(() => _selectedFilter = name),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }
                  ),
                ),

                // Project count + sort
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          '${projects.length} PROJECTS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.sort_rounded, size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Project list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProjectDetailScreen(project: project),
                              ),
                            );
                          },
                          onMarkContacted: () {
                            _projectService.markContacted(project);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Marked "${project.projectName}" as contacted'),
                              ),
                            );
                          },
                        );
                      },
                      childCount: projects.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: theme.dividerColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: isSelected ? AppTheme.primary : theme.dividerColor)
              : (isSelected ? Border.all(color: AppTheme.primary) : null),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryLight
                    : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Widget {
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}
