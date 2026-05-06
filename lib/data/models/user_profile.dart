class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final DateTime createdAt;
  final bool darkMode;
  final bool onboardingDone;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.createdAt,
    this.darkMode = false,
    this.onboardingDone = false,
  });

  UserProfile copyWith({
    String? displayName,
    bool? darkMode,
    bool? onboardingDone,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email,
        createdAt: createdAt,
        darkMode: darkMode ?? this.darkMode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
        'darkMode': darkMode,
        'onboardingDone': onboardingDone,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String? ?? 'Friend',
        email: map['email'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
        darkMode: (map['darkMode'] as bool?) ?? false,
        onboardingDone: (map['onboardingDone'] as bool?) ?? false,
      );
}
