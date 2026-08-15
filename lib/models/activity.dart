import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  created,
  statusChange,
  priorityChange,
  assignedChange,
  noteUpdated,
  contacted,
  reminderSet,
  reminderSnoozed,
  callMade,
  proposalSent,
  projectWon,
  other,
}

class Activity {
  final String id;
  final String projectId;
  final String projectName;
  final ActivityType type;
  final String title;
  final String? description;
  final String? oldValue;
  final String? newValue;
  final String performedById;
  final String performedByName;
  final String performedByInitial;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.type,
    required this.title,
    this.description,
    this.oldValue,
    this.newValue,
    required this.performedById,
    required this.performedByName,
    required this.performedByInitial,
    required this.timestamp,
  });

  /// Human readable time ago
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  /// Icon / emoji for the activity type
  String get icon {
    switch (type) {
      case ActivityType.created:
        return '➕';
      case ActivityType.statusChange:
        return '🔄';
      case ActivityType.contacted:
        return '✓';
      case ActivityType.callMade:
        return '📞';
      case ActivityType.proposalSent:
        return '📄';
      case ActivityType.projectWon:
        return '🏆';
      case ActivityType.noteUpdated:
        return '📝';
      case ActivityType.reminderSet:
      case ActivityType.reminderSnoozed:
        return '⏰';
      default:
        return '•';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'type': type.name,
      'title': title,
      'description': description,
      'oldValue': oldValue,
      'newValue': newValue,
      'performedById': performedById,
      'performedByName': performedByName,
      'performedByInitial': performedByInitial,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return Activity(
      id: docId ?? map['id'] ?? map['uid'] ?? '',
      projectId: map['projectId'] ?? '',
      projectName: map['projectName'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.other,
      ),
      title: map['title'] ?? '',
      description: map['description'],
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      performedById: map['performedById'] ?? '',
      performedByName: map['performedByName'] ?? '',
      performedByInitial: map['performedByInitial'] ?? '',
      timestamp: parseDateTime(map['timestamp']),
    );
  }
}
