import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/project.dart';
import '../models/activity.dart';
import '../models/user.dart' as app_user;
import 'auth_service.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // ──────────── Stream of Projects ────────────
  Stream<List<Project>> getActiveProjectsStream() {
    return _db
        .collection('projects')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Project.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ──────────── Stream of Single Project ────────────
  Stream<Project?> getProjectStream(String projectId) {
    return _db.collection('projects').doc(projectId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Project.fromMap(doc.data()!, docId: doc.id);
    });
  }

  // ──────────── Stream of Project Activities ────────────
  Stream<List<Activity>> getProjectActivitiesStream(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('activities')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Activity.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  // ──────────── Stream of Global Activity Feed ────────────
  Stream<List<Activity>> getGlobalActivitiesStream() {
    return _db.collection('activityFeed').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Activity.fromMap(doc.data(), docId: doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  // ──────────── Add Project ────────────
  Future<void> addProject(Project project) async {
    final docRef = _db
        .collection('projects')
        .doc(project.id.isNotEmpty ? project.id : null);
    final projectId = docRef.id;

    final currentUserDoc = await AuthService().getCurrentAppUser();
    final performedByName = currentUserDoc?.name.split(' ').first ?? 'User';
    final performedByInitial = currentUserDoc?.initial ?? 'U';
    final performedById = _auth.currentUser?.uid ?? '';

    final projectWithId = project.copyWith(
      id: projectId,
      createdById: performedById,
      createdByName: performedByName,
      createdAt: DateTime.now(),
      lastContactAt: DateTime.now(),
    );

    await docRef.set(projectWithId.toMap());

    final activityId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final activity = Activity(
      id: activityId,
      projectId: projectId,
      projectName: project.projectName,
      type: ActivityType.created,
      title: 'Project Created: ${project.projectName}',
      description:
          project.notes.isNotEmpty ? project.notes : 'Added to workspace',
      performedById: performedById,
      performedByName: performedByName,
      performedByInitial: performedByInitial,
      timestamp: DateTime.now(),
    );

    await logActivity(activity);
  }

  // ──────────── Update Project ────────────
  Future<void> updateProject(Project project) async {
    final currentUserDoc = await AuthService().getCurrentAppUser();
    final performedByName = currentUserDoc?.name.split(' ').first ?? 'User';
    final performedByInitial = currentUserDoc?.initial ?? 'U';
    final performedById = _auth.currentUser?.uid ?? '';

    final updatedProject = project.copyWith(
      updatedAt: DateTime.now(),
      updatedBy: performedById,
    );

    await _db
        .collection('projects')
        .doc(project.id)
        .update(updatedProject.toMap());

    // Log update activity
    final activityId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final activity = Activity(
      id: activityId,
      projectId: project.id,
      projectName: project.projectName,
      type: ActivityType.statusChange,
      title: 'Project Updated: ${project.projectName}',
      description: 'Modified project parameters and options',
      performedById: performedById,
      performedByName: performedByName,
      performedByInitial: performedByInitial,
      timestamp: DateTime.now(),
    );

    await logActivity(activity);
  }

  // ──────────── Mark Contacted ────────────
  Future<void> markContacted(Project project) async {
    final currentUserDoc = await AuthService().getCurrentAppUser();
    final performedByName = currentUserDoc?.name.split(' ').first ?? 'User';
    final performedByInitial = currentUserDoc?.initial ?? 'U';
    final performedById = _auth.currentUser?.uid ?? '';

    final now = DateTime.now();

    await _db.collection('projects').doc(project.id).update({
      'lastContactAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'updatedBy': performedById,
    });

    final activityId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final activity = Activity(
      id: activityId,
      projectId: project.id,
      projectName: project.projectName,
      type: ActivityType.contacted,
      title: 'Marked as Contacted on ${project.projectName}',
      description: 'Discussed project updates and next steps',
      performedById: performedById,
      performedByName: performedByName,
      performedByInitial: performedByInitial,
      timestamp: now,
    );

    await logActivity(activity);
  }

  // ──────────── Snooze Project ────────────
  Future<void> snoozeProject({
    required String projectId,
    required DateTime reminderAt,
    required DateTime reminderSnoozedUntil,
  }) async {
    final currentUserDoc = await AuthService().getCurrentAppUser();
    final performedByName = currentUserDoc?.name.split(' ').first ?? 'User';
    final performedByInitial = currentUserDoc?.initial ?? 'U';
    final performedById = _auth.currentUser?.uid ?? '';

    final projectDoc = await _db.collection('projects').doc(projectId).get();
    if (!projectDoc.exists || projectDoc.data() == null) return;
    final project = Project.fromMap(projectDoc.data()!, docId: projectDoc.id);

    final now = DateTime.now();

    await _db.collection('projects').doc(projectId).update({
      'reminderAt': Timestamp.fromDate(reminderAt),
      'reminderSnoozedUntil': Timestamp.fromDate(reminderSnoozedUntil),
      'updatedAt': Timestamp.fromDate(now),
      'updatedBy': performedById,
    });

    final activityId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final activity = Activity(
      id: activityId,
      projectId: projectId,
      projectName: project.projectName,
      type: ActivityType.reminderSnoozed,
      title: 'Follow-up Snoozed on ${project.projectName}',
      description:
          'Snoozed until ${reminderSnoozedUntil.hour.toString().padLeft(2, "0")}:${reminderSnoozedUntil.minute.toString().padLeft(2, "0")}',
      performedById: performedById,
      performedByName: performedByName,
      performedByInitial: performedByInitial,
      timestamp: now,
    );

    await logActivity(activity);
  }

  // ──────────── Snooze Reminder Helper ────────────
  Future<void> snoozeReminder(Project project, int minutes) async {
    final now = DateTime.now();
    final snoozeTime = now.add(Duration(minutes: minutes));
    await snoozeProject(
      projectId: project.id,
      reminderAt: project.reminderAt ?? now,
      reminderSnoozedUntil: snoozeTime,
    );
  }

  // ──────────── Complete Reminder Helper ────────────
  Future<void> completeReminder(Project project) async {
    final currentUserDoc = await AuthService().getCurrentAppUser();
    final performedByName = currentUserDoc?.name.split(' ').first ?? 'User';
    final performedByInitial = currentUserDoc?.initial ?? 'U';
    final performedById = _auth.currentUser?.uid ?? '';

    final now = DateTime.now();

    await _db.collection('projects').doc(project.id).update({
      'reminderAt': null,
      'reminderSnoozedUntil': null,
      'lastContactAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'updatedBy': performedById,
    });

    final activityId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final activity = Activity(
      id: activityId,
      projectId: project.id,
      projectName: project.projectName,
      type: ActivityType.contacted,
      title: 'Action Completed: ${project.nextAction}',
      description: 'Completed scheduled task successfully',
      performedById: performedById,
      performedByName: performedByName,
      performedByInitial: performedByInitial,
      timestamp: now,
    );

    await logActivity(activity);
  }

  // ──────────── Soft Delete ────────────
  Future<void> softDeleteProject(String projectId) async {
    final projectDoc = await _db.collection('projects').doc(projectId).get();
    if (!projectDoc.exists || projectDoc.data() == null) return;
    final project = Project.fromMap(projectDoc.data()!, docId: projectDoc.id);

    final currentUserDoc = await AuthService().getCurrentAppUser();
    final performedByName = currentUserDoc?.name.split(' ').first ?? 'User';
    final performedByInitial = currentUserDoc?.initial ?? 'U';
    final performedById = _auth.currentUser?.uid ?? '';

    await _db.collection('projects').doc(projectId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final activityId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final activity = Activity(
      id: activityId,
      projectId: projectId,
      projectName: project.projectName,
      type: ActivityType.statusChange,
      title: 'Project Deleted: ${project.projectName}',
      description: 'Removed project from active workspace',
      performedById: performedById,
      performedByName: performedByName,
      performedByInitial: performedByInitial,
      timestamp: DateTime.now(),
    );

    await logActivity(activity);
  }

  // ──────────── Log Activity Helper ────────────
  Future<void> logActivity(Activity activity) async {
    await _db
        .collection('projects')
        .doc(activity.projectId)
        .collection('activities')
        .doc(activity.id)
        .set(activity.toMap());

    await _db.collection('activityFeed').doc(activity.id).set({
      ...activity.toMap(),
      'projectName': activity.projectName,
    });
  }
}
