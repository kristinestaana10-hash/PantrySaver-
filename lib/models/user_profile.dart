class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final double monthlyBudget;
  final DateTime createdAt;
  final bool notificationsEnabled;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.monthlyBudget,
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'monthlyBudget': monthlyBudget,
        'createdAt': createdAt.toIso8601String(),
        'notificationsEnabled': notificationsEnabled,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] ?? '',
        fullName: map['fullName'] ?? '',
        email: map['email'] ?? '',
        monthlyBudget: (map['monthlyBudget'] ?? 0).toDouble(),
        createdAt: map['createdAt'] is String
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
        notificationsEnabled: map['notificationsEnabled'] ?? true,
      );
}
