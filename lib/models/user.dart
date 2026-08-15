class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String initial;
  final String role; // super_admin | admin | member
  final String? avatarColor;
  final bool isActive;
  final String notifications;     // 'All' | 'Muted'
  final String defaultReminder;   // e.g., '10:00 AM'
  final String timeZone;          // e.g., 'Automatic'

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.initial,
    this.role = 'member',
    this.avatarColor,
    this.isActive = true,
    this.notifications = 'All',
    this.defaultReminder = '10:00 AM',
    this.timeZone = 'Automatic',
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      initial: map['initial'] ?? '',
      role: map['role'] ?? 'member',
      avatarColor: map['avatarColor'],
      isActive: map['isActive'] ?? true,
      notifications: map['notifications'] ?? 'All',
      defaultReminder: map['defaultReminder'] ?? '10:00 AM',
      timeZone: map['timeZone'] ?? 'Automatic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'phone': phone,
      'initial': initial,
      'role': role,
      'avatarColor': avatarColor,
      'isActive': isActive,
      'notifications': notifications,
      'defaultReminder': defaultReminder,
      'timeZone': timeZone,
    };
  }
}
