import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<UserProfile> ensureProfileForUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString(_avatarKey(user.uid));
    final avatarBytes = _avatarBytesFromPrefs(prefs, user.uid);
    final preferredLanguage = _normalizeLanguageCode(
      prefs.getString('language_code') ??
          PlatformDispatcher.instance.locale.languageCode,
    );
    final snapshot = await _userDoc(user.uid).get();

    if (!snapshot.exists) {
      final profile = UserProfile.fallback(
        user,
        localAvatarPath: avatarPath,
        localAvatarBytes: avatarBytes,
        languageCode: preferredLanguage,
      );
      await _userDoc(user.uid)
          .set(profile.toDocument(), SetOptions(merge: true));
      return profile;
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    final hydrated = UserProfile.fromMap(
      user.uid,
      {
        ...data,
        'displayName': data['displayName'] ?? user.displayName,
        'email': user.email ?? data['email'],
      },
      localAvatarPath: avatarPath,
      localAvatarBytes: avatarBytes,
    );

    final profileRefresh = <String, dynamic>{
      'displayName': hydrated.displayName,
      'email': hydrated.email,
      'planName': hydrated.planName,
      'subscriptionStatus': hydrated.subscriptionStatus,
      'avatarSeed': hydrated.avatarSeed,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (data['pendingEmail'] == user.email) {
      profileRefresh['pendingEmail'] = FieldValue.delete();
    }

    await _userDoc(user.uid).set(profileRefresh, SetOptions(merge: true));

    return hydrated;
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _userDoc(uid).snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      return UserProfile.fromMap(
        uid,
        snapshot.data() ?? <String, dynamic>{},
        localAvatarPath: prefs.getString(_avatarKey(uid)),
        localAvatarBytes: _avatarBytesFromPrefs(prefs, uid),
      );
    });
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required int avatarSeed,
    String? avatarSourcePath,
    Uint8List? avatarBytes,
    bool removeAvatar = false,
  }) async {
    final user = _requireUser();
    final normalizedName =
        displayName.trim().isEmpty ? 'Aria User' : displayName.trim();
    var normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      normalizedEmail = user.email ?? '';
    }

    if (normalizedName != (user.displayName ?? '')) {
      await user.updateDisplayName(normalizedName);
    }

    String? pendingEmail;
    if (normalizedEmail.isNotEmpty && normalizedEmail != (user.email ?? '')) {
      await user.verifyBeforeUpdateEmail(normalizedEmail);
      pendingEmail = normalizedEmail;
      normalizedEmail = user.email ?? normalizedEmail;
    }

    if (removeAvatar) {
      await _clearAvatar(user.uid);
    } else if (avatarBytes != null && avatarBytes.isNotEmpty) {
      await _persistAvatarBytes(user.uid, avatarBytes);
    } else if (avatarSourcePath != null && avatarSourcePath.trim().isNotEmpty) {
      await _persistAvatarPath(user.uid, avatarSourcePath);
    }

    await _userDoc(user.uid).set(
      {
        'displayName': normalizedName,
        'email': normalizedEmail,
        if (pendingEmail != null) 'pendingEmail': pendingEmail,
        'avatarSeed': avatarSeed,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updatePreferences({
    String? themeMode,
    String? languageCode,
    bool? aiAutoPlanning,
    bool? smartPrioritization,
    bool? smartReminders,
    bool? focusMode,
    bool? pushNotifications,
    bool? dailyDigest,
    bool? weeklyReport,
  }) async {
    final user = _requireUser();
    final preferenceUpdates = <String, dynamic>{};

    if (aiAutoPlanning != null) {
      preferenceUpdates['aiAutoPlanning'] = aiAutoPlanning;
    }
    if (smartPrioritization != null) {
      preferenceUpdates['smartPrioritization'] = smartPrioritization;
    }
    if (smartReminders != null) {
      preferenceUpdates['smartReminders'] = smartReminders;
    }
    if (focusMode != null) {
      preferenceUpdates['focusMode'] = focusMode;
    }
    if (pushNotifications != null) {
      preferenceUpdates['pushNotifications'] = pushNotifications;
    }
    if (dailyDigest != null) {
      preferenceUpdates['dailyDigest'] = dailyDigest;
    }
    if (weeklyReport != null) {
      preferenceUpdates['weeklyReport'] = weeklyReport;
    }

    final document = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (themeMode != null) {
      document['themeMode'] = themeMode;
    }
    if (languageCode != null) {
      document['languageCode'] = languageCode;
    }
    if (preferenceUpdates.isNotEmpty) {
      document['preferences'] = preferenceUpdates;
    }

    await _userDoc(user.uid).set(document, SetOptions(merge: true));
  }

  Future<void> removeAvatar() async {
    await _clearAvatar(_requireUser().uid);
  }

  Future<void> updateSubscription({
    required String planName,
    required String status,
    required DateTime? startedAt,
    required DateTime? renewsAt,
    required String? receiptId,
  }) async {
    final user = _requireUser();
    final document = <String, dynamic>{
      'planName': planName,
      'subscriptionStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (startedAt == null) {
      document['subscriptionStartedAt'] = FieldValue.delete();
    } else {
      document['subscriptionStartedAt'] = Timestamp.fromDate(startedAt);
    }

    if (renewsAt == null) {
      document['subscriptionRenewsAt'] = FieldValue.delete();
    } else {
      document['subscriptionRenewsAt'] = Timestamp.fromDate(renewsAt);
    }

    if (receiptId == null) {
      document['subscriptionReceiptId'] = FieldValue.delete();
    } else {
      document['subscriptionReceiptId'] = receiptId;
    }

    await _userDoc(user.uid).set(document, SetOptions(merge: true));
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return user;
  }

  Future<void> _persistAvatarBytes(String uid, Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarBytesKey(uid), base64Encode(bytes));
    await prefs.remove(_avatarKey(uid));
  }

  Future<void> _persistAvatarPath(String uid, String sourcePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey(uid), sourcePath);
    await prefs.remove(_avatarBytesKey(uid));
  }

  Future<void> _clearAvatar(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarKey(uid));
    await prefs.remove(_avatarBytesKey(uid));
  }

  String _avatarKey(String uid) => 'avatar_path_$uid';
  String _avatarBytesKey(String uid) => 'avatar_bytes_$uid';

  Uint8List? _avatarBytesFromPrefs(SharedPreferences prefs, String uid) {
    final encoded = prefs.getString(_avatarBytesKey(uid));
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      return Uint8List.fromList(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  String _normalizeLanguageCode(String value) {
    return value.toLowerCase().startsWith('ru') ? 'ru' : 'en';
  }
}
