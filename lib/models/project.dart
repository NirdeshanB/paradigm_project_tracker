import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String projectName;
  final String contactName;
  final String contactNumber;
  final String company;
  final String projectType;
  final String status;
  final String assignedToId;
  final String assignedToName;
  final String assignedToInitial;
  final String priority; // High | Medium | Low
  final double? estimatedValue;
  final String nextAction;
  final DateTime? reminderAt;
  final DateTime? reminderSnoozedUntil;
  final DateTime lastContactAt;
  final DateTime createdAt;
  final String createdById;
  final String createdByName;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String notes;
  final List<String> tags;
  final bool isDeleted;
  final String currency;

  Project({
    required this.id,
    required this.projectName,
    required this.contactName,
    required this.contactNumber,
    required this.company,
    this.projectType = '',
    required this.status,
    required this.assignedToId,
    required this.assignedToName,
    required this.assignedToInitial,
    required this.priority,
    this.estimatedValue,
    required this.nextAction,
    this.reminderAt,
    this.reminderSnoozedUntil,
    required this.lastContactAt,
    required this.createdAt,
    required this.createdById,
    required this.createdByName,
    this.updatedAt,
    this.updatedBy,
    this.notes = '',
    this.tags = const [],
    this.isDeleted = false,
    this.currency = '\$',
  });

  /// Days since last contact (calculated)
  int get daysSinceContact {
    return DateTime.now().difference(lastContactAt).inDays;
  }

  /// Whether the follow-up is overdue (more than 7 days)
  bool get isOverdue => daysSinceContact > 7;

  /// Formatted estimated value
  String get formattedValue {
    if (estimatedValue == null) return '—';
    final sym = currency == 'IC' ? '₹' : currency;
    return '$sym${estimatedValue!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Copy with method for easy updates
  Project copyWith({
    String? id,
    String? projectName,
    String? contactName,
    String? contactNumber,
    String? company,
    String? projectType,
    String? status,
    String? assignedToId,
    String? assignedToName,
    String? assignedToInitial,
    String? priority,
    double? estimatedValue,
    String? nextAction,
    DateTime? reminderAt,
    DateTime? reminderSnoozedUntil,
    DateTime? lastContactAt,
    DateTime? createdAt,
    String? createdById,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedBy,
    String? notes,
    List<String>? tags,
    bool? isDeleted,
    String? currency,
  }) {
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      contactName: contactName ?? this.contactName,
      contactNumber: contactNumber ?? this.contactNumber,
      company: company ?? this.company,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedToInitial: assignedToInitial ?? this.assignedToInitial,
      priority: priority ?? this.priority,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      nextAction: nextAction ?? this.nextAction,
      reminderAt: reminderAt ?? this.reminderAt,
      reminderSnoozedUntil: reminderSnoozedUntil ?? this.reminderSnoozedUntil,
      lastContactAt: lastContactAt ?? this.lastContactAt,
      createdAt: createdAt ?? this.createdAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
      currency: currency ?? this.currency,
    );
  }

  /// Convert to Map (useful later for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectName': projectName,
      'contactName': contactName,
      'contactNumber': contactNumber,
      'company': company,
      'projectType': projectType,
      'status': status,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'assignedToInitial': assignedToInitial,
      'priority': priority,
      'estimatedValue': estimatedValue,
      'nextAction': nextAction,
      'reminderAt': reminderAt != null ? Timestamp.fromDate(reminderAt!) : null,
      'reminderSnoozedUntil': reminderSnoozedUntil != null ? Timestamp.fromDate(reminderSnoozedUntil!) : null,
      'lastContactAt': Timestamp.fromDate(lastContactAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdById': createdById,
      'createdByName': createdByName,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
      'notes': notes,
      'tags': tags,
      'isDeleted': isDeleted,
      'currency': currency,
    };
  }

  /// Create from Map
  factory Project.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return Project(
      id: docId ?? map['id'] ?? map['uid'] ?? '',
      projectName: map['projectName'] ?? '',
      contactName: map['contactName'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      company: map['company'] ?? '',
      projectType: map['projectType'] ?? '',
      status: map['status'] ?? '',
      assignedToId: map['assignedToId'] ?? '',
      assignedToName: map['assignedToName'] ?? '',
      assignedToInitial: map['assignedToInitial'] ?? '',
      priority: map['priority'] ?? 'Medium',
      estimatedValue: map['estimatedValue']?.toDouble(),
      nextAction: map['nextAction'] ?? '',
      reminderAt: parseDateTime(map['reminderAt']),
      reminderSnoozedUntil: parseDateTime(map['reminderSnoozedUntil']),
      lastContactAt: parseDateTime(map['lastContactAt']) ?? DateTime.now(),
      createdAt: parseDateTime(map['createdAt']) ?? DateTime.now(),
      createdById: map['createdById'] ?? '',
      createdByName: map['createdByName'] ?? '',
      updatedAt: parseDateTime(map['updatedAt']),
      updatedBy: map['updatedBy'],
      notes: map['notes'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isDeleted: map['isDeleted'] ?? false,
      currency: map['currency'] ?? '\$',
    );
  }
}
