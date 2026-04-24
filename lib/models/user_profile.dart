import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.themeModeName,
    required this.languageCode,
    required this.aiAutoPlanning,
    required this.smartPrioritization,
    required this.smartReminders,
    required this.focusMode,
    required this.pushNotifications,
    required this.dailyDigest,
    required this.weeklyReport,
    required this.planName,
    required this.avatarSeed,
    this.localAvatarPath,
    this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String themeModeName;
  final String languageCode;
  final bool aiAutoPlanning;
  final bool smartPrioritization;
  final bool smartReminders;
  final bool focusMode;
  final bool pushNotifications;
  final bool dailyDigest;
  final bool weeklyReport;
  final String planName;
  final int avatarSeed;
  final String? localAvatarPath;
  final DateTime? updatedAt;

  factory UserProfile.fromMap(
    String uid,
    Map<String, dynamic> data, {
    String? localAvatarPath,
  }) {
    final preferences = (data['preferences'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    return UserProfile(
      uid: uid,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? (data['displayName'] as String).trim()
          : _defaultDisplayName(data['email'] as String?),
      email: (data['email'] as String?)?.trim() ?? '',
      themeModeName: (data['themeMode'] as String?) ?? 'light',
      languageCode: (data['languageCode'] as String?) ?? 'en',
      aiAutoPlanning: preferences['aiAutoPlanning'] as bool? ?? true,
      smartPrioritization: preferences['smartPrioritization'] as bool? ?? true,
      smartReminders: preferences['smartReminders'] as bool? ?? true,
      focusMode: preferences['focusMode'] as bool? ?? false,
      pushNotifications: preferences['pushNotifications'] as bool? ?? true,
      dailyDigest: preferences['dailyDigest'] as bool? ?? true,
      weeklyReport: preferences['weeklyReport'] as bool? ?? true,
      planName: (data['planName'] as String?) ?? 'Pro',
      avatarSeed: data['avatarSeed'] as int? ?? 0,
      localAvatarPath: localAvatarPath,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserProfile.fallback(
    User user, {
    String? localAvatarPath,
    String languageCode = 'en',
  }) {
    return UserProfile(
      uid: user.uid,
      displayName: _defaultDisplayName(user.email, user.displayName),
      email: user.email ?? '',
      themeModeName: 'light',
      languageCode: languageCode,
      aiAutoPlanning: true,
      smartPrioritization: true,
      smartReminders: true,
      focusMode: false,
      pushNotifications: true,
      dailyDigest: true,
      weeklyReport: true,
      planName: 'Pro',
      avatarSeed: user.uid.hashCode.abs() % 6,
      localAvatarPath: localAvatarPath,
      updatedAt: null,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? themeModeName,
    String? languageCode,
    bool? aiAutoPlanning,
    bool? smartPrioritization,
    bool? smartReminders,
    bool? focusMode,
    bool? pushNotifications,
    bool? dailyDigest,
    bool? weeklyReport,
    String? planName,
    int? avatarSeed,
    String? localAvatarPath,
    bool clearAvatarPath = false,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      themeModeName: themeModeName ?? this.themeModeName,
      languageCode: languageCode ?? this.languageCode,
      aiAutoPlanning: aiAutoPlanning ?? this.aiAutoPlanning,
      smartPrioritization: smartPrioritization ?? this.smartPrioritization,
      smartReminders: smartReminders ?? this.smartReminders,
      focusMode: focusMode ?? this.focusMode,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      weeklyReport: weeklyReport ?? this.weeklyReport,
      planName: planName ?? this.planName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      localAvatarPath:
          clearAvatarPath ? null : (localAvatarPath ?? this.localAvatarPath),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'displayName': displayName,
      'email': email,
      'themeMode': themeModeName,
      'languageCode': languageCode,
      'planName': planName,
      'avatarSeed': avatarSeed,
      'preferences': {
        'aiAutoPlanning': aiAutoPlanning,
        'smartPrioritization': smartPrioritization,
        'smartReminders': smartReminders,
        'focusMode': focusMode,
        'pushNotifications': pushNotifications,
        'dailyDigest': dailyDigest,
        'weeklyReport': weeklyReport,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String _defaultDisplayName(String? email, [String? displayName]) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final normalizedEmail = email?.trim() ?? '';
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'Aria User';
    }

    final localPart = normalizedEmail.split('@').first.replaceAll('.', ' ');
    final pieces = localPart
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .toList();

    return pieces.isEmpty ? 'Aria User' : pieces.join(' ');
  }
}
