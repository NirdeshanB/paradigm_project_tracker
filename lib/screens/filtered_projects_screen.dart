import 'package:flutter/material.dart';


import '../models/project.dart';
import '../widgets/project_card.dart';
import 'project_detail_screen.dart';
import '../services/project_service.dart';

class FilteredProjectsScreen extends StatelessWidget {
  final String title;
  final List<Project> projects;

  const FilteredProjectsScreen({
    super.key,
    required this.title,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(fontFamily: 'Outfit', 
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineMedium?.color,
          ),
        ),
      ),
      body: SafeArea(
        child: projects.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 64,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No projects found',
                      style: TextStyle(fontFamily: 'Outfit', 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(project: project),
                        ),
                      );
                    },
                    onMarkContacted: () {
                      ProjectService().markContacted(project);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marked "${project.projectName}" as contacted'),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
