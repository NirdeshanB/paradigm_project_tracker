import '../models/project.dart';
import '../models/user.dart';
import '../models/activity.dart';

class MockData {
  // ─────────────────────────────
  // Team Members
  // ─────────────────────────────
  static final List<User> users = [
    User(
      id: 'user_alex',
      name: 'Alex Rivera',
      email: 'alex@paradigmdigital.co',
      initial: 'A',
      role: 'admin',
      avatarColor: '#4F46E5',
    ),
    User(
      id: 'user_jordan',
      name: 'Jordan Kim',
      email: 'jordan@paradigmdigital.co',
      initial: 'J',
      role: 'member',
      avatarColor: '#7C3AED',
    ),
    User(
      id: 'user_sam',
      name: 'Sam Okonkwo',
      email: 'sam@paradigmdigital.co',
      initial: 'S',
      role: 'member',
      avatarColor: '#0EA5E9',
    ),
  ];

  static User get currentUser => users[0]; // Alex

  // ─────────────────────────────
  // Projects
  // ─────────────────────────────
  static final List<Project> projects = [
    Project(
      id: 'proj_001',
      projectName: 'Meridian Hospitality Rebrand',
      contactName: 'Sarah Chen',
      contactNumber: '+1 (415) 823-4491',
      company: 'Meridian Hotels Group',
      projectType: 'Branding',
      status: 'Active',
      assignedToId: 'user_alex',
      assignedToName: 'Alex',
      assignedToInitial: 'A',
      priority: 'High',
      estimatedValue: 24500,
      nextAction: 'Send revised brand deck',
      reminderAt: DateTime.now().add(const Duration(hours: 4)),
      lastContactAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      createdById: 'user_alex',
      createdByName: 'Alex',
      notes:
          'Client wants to see a complete rebrand including logo, website, and print collateral. Budget confirmed.',
      tags: ['#branding', '#web'],
    ),
    Project(
      id: 'proj_002',
      projectName: 'Volta EV Platform',
      contactName: 'Marcus Reid',
      contactNumber: '+1 (628) 301-7734',
      company: 'Volta Motors',
      projectType: 'Web App',
      status: 'Proposal',
      assignedToId: 'user_jordan',
      assignedToName: 'Jordan',
      assignedToInitial: 'J',
      priority: 'High',
      estimatedValue: 61000,
      nextAction: 'Follow up on proposal #VP-2024',
      reminderAt: DateTime.now().add(const Duration(days: 1, hours: 10)),
      lastContactAt: DateTime.now().subtract(const Duration(days: 9)),
      createdAt: DateTime.now().subtract(const Duration(days: 24)),
      createdById: 'user_jordan',
      createdByName: 'Jordan',
      notes:
          'Large SaaS dashboard for EV fleet management. Decision expected after internal review.',
      tags: ['#saas', '#dashboard'],
    ),
    Project(
      id: 'proj_003',
      projectName: 'Bloom Wellness App',
      contactName: 'Priya Sharma',
      contactNumber: '+1 (312) 554-8820',
      company: 'Bloom Health Co.',
      projectType: 'Mobile App',
      status: 'Active',
      assignedToId: 'user_sam',
      assignedToName: 'Sam',
      assignedToInitial: 'S',
      priority: 'Medium',
      estimatedValue: 18200,
      nextAction: 'Schedule wireframe review call',
      reminderAt:
          DateTime.now().add(const Duration(days: 2, hours: 11, minutes: 30)),
      lastContactAt: DateTime.now().subtract(const Duration(days: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      createdById: 'user_sam',
      createdByName: 'Sam',
      notes:
          'iOS + Android wellness tracking app. Wireframes almost ready for review.',
      tags: ['#mobile', '#health'],
    ),
    Project(
      id: 'proj_004',
      projectName: 'Rooftop Collective Branding',
      contactName: 'Elena Vargas',
      contactNumber: '+1 (503) 441-2290',
      company: 'Rooftop Collective',
      projectType: 'Branding',
      status: 'New',
      assignedToId: 'user_alex',
      assignedToName: 'Alex',
      assignedToInitial: 'A',
      priority: 'Low',
      estimatedValue: 8500,
      nextAction: 'Intro discovery call',
      reminderAt: DateTime.now().add(const Duration(days: 3, hours: 15)),
      lastContactAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      createdById: 'user_alex',
      createdByName: 'Alex',
      notes:
          'Referral from Meridian. Small boutique hotel group looking for brand identity.',
      tags: ['#branding'],
    ),
    Project(
      id: 'proj_005',
      projectName: 'NovaTech SaaS Dashboard',
      contactName: 'David Park',
      contactNumber: '+1 (650) 788-3312',
      company: 'NovaTech Inc.',
      projectType: 'Web App',
      status: 'On Hold',
      assignedToId: 'user_jordan',
      assignedToName: 'Jordan',
      assignedToInitial: 'J',
      priority: 'Medium',
      estimatedValue: 32000,
      nextAction: 'Re-engage after internal review',
      reminderAt: DateTime.now().add(const Duration(days: 5, hours: 9)),
      lastContactAt: DateTime.now().subtract(const Duration(days: 14)),
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
      createdById: 'user_jordan',
      createdByName: 'Jordan',
      notes:
          'Moved to On Hold — client budget review pending. Strong interest still exists.',
      tags: ['#saas', '#b2b'],
    ),
    Project(
      id: 'proj_006',
      projectName: 'Cascade Legal Website',
      contactName: 'Amanda Foster',
      contactNumber: '+1 (206) 992-4471',
      company: 'Cascade Legal Partners',
      projectType: 'Website',
      status: 'Won',
      assignedToId: 'user_sam',
      assignedToName: 'Sam',
      assignedToInitial: 'S',
      priority: 'Low',
      estimatedValue: 14800,
      nextAction: 'Kick-off meeting prep',
      reminderAt: DateTime.now().add(const Duration(days: 2, hours: 13)),
      lastContactAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
      createdById: 'user_sam',
      createdByName: 'Sam',
      notes:
          'Contract signed for \$14,800. Kick-off scheduled. Need to prepare project plan.',
      tags: ['#website', '#legal'],
    ),
  ];

  // ─────────────────────────────
  // Activity Feed
  // ─────────────────────────────
  static final List<Activity> activities = [
    Activity(
      id: 'act_001',
      projectId: 'proj_001',
      projectName: 'Meridian Hospitality Rebrand',
      type: ActivityType.contacted,
      title: 'Marked as Contacted on Meridian Hospitality Rebrand',
      description: 'Discussed budget and timeline in depth',
      performedById: 'user_alex',
      performedByName: 'Alex',
      performedByInitial: 'A',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Activity(
      id: 'act_002',
      projectId: 'proj_006',
      projectName: 'Cascade Legal Website',
      type: ActivityType.projectWon,
      title: 'Project Won 🎉 on Cascade Legal Website',
      description: 'Contract signed for \$14,800',
      performedById: 'user_sam',
      performedByName: 'Sam',
      performedByInitial: 'S',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Activity(
      id: 'act_003',
      projectId: 'proj_003',
      projectName: 'Bloom Wellness App',
      type: ActivityType.callMade,
      title: 'Call Made on Bloom Wellness App',
      description: '22-minute call, discussed UX flow',
      performedById: 'user_sam',
      performedByName: 'Sam',
      performedByInitial: 'S',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    Activity(
      id: 'act_004',
      projectId: 'proj_004',
      projectName: 'Rooftop Collective Branding',
      type: ActivityType.created,
      title: 'Project Created on Rooftop Collective Branding',
      description: 'Added via referral from Meridian',
      performedById: 'user_alex',
      performedByName: 'Alex',
      performedByInitial: 'A',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    ),
    Activity(
      id: 'act_005',
      projectId: 'proj_002',
      projectName: 'Volta EV Platform',
      type: ActivityType.proposalSent,
      title: 'Sent Proposal on Volta EV Platform',
      description: 'Proposal #VP-2024 delivered via email',
      performedById: 'user_jordan',
      performedByName: 'Jordan',
      performedByInitial: 'J',
      timestamp: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Activity(
      id: 'act_006',
      projectId: 'proj_001',
      projectName: 'Meridian Hospitality Rebrand',
      type: ActivityType.noteUpdated,
      title: 'Added Note on Meridian Hospitality Rebrand',
      description: 'Client confirmed Q1 start date',
      performedById: 'user_jordan',
      performedByName: 'Jordan',
      performedByInitial: 'J',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Activity(
      id: 'act_007',
      projectId: 'proj_005',
      projectName: 'NovaTech SaaS Dashboard',
      type: ActivityType.statusChange,
      title: 'Status Changed on NovaTech SaaS Dashboard',
      description: 'Moved to On Hold — budget review pending',
      oldValue: 'Active',
      newValue: 'On Hold',
      performedById: 'user_jordan',
      performedByName: 'Jordan',
      performedByInitial: 'J',
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  // ─────────────────────────────
  // Dropdown / Config values
  // ─────────────────────────────
  static const List<String> statuses = [
    'New',
    'Active',
    'Proposal',
    'On Hold',
    'Won',
    'Cancelled',
    'Unreachable',
  ];

  static const List<String> priorities = [
    'High',
    'Medium',
    'Low',
  ];

  static const List<String> nextActions = [
    'Call',
    'WhatsApp',
    'Office Visit',
    'Demo',
    'Quotation',
    'Follow-up',
    'Send revised brand deck',
    'Schedule wireframe review call',
    'Intro discovery call',
    'Kick-off meeting prep',
    'Re-engage after internal review',
  ];

  static const List<String> projectTypes = [
    'Branding',
    'Website',
    'Web App',
    'Mobile App',
    'UI/UX Design',
    'Other',
  ];
}
