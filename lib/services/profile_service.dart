import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
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
    final snapshot = await _userDoc(user.uid).get();

    if (!snapshot.exists) {
      final profile = UserProfile.fallback(user, localAvatarPath: avatarPath);
      await _userDoc(user.uid).set(profile.toDocument(), SetOptions(merge: true));
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
    );

    await _userDoc(user.uid).set(
      {
        'displayName': hydrated.displayName,
        'email': hydrated.email,
        'avatarSeed': hydrated.avatarSeed,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

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
      );
    });
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required int avatarSeed,
    String? avatarSourcePath,
    bool removeAvatar = false,
  }) async {
    final user = _requireUser();
    final normalizedName = displayName.trim().isEmpty ? 'Aria User' : displayName.trim();
    var normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      normalizedEmail = user.email ?? '';
    }

    if (normalizedName != (user.displayName ?? '')) {
      await user.updateDisplayName(normalizedName);
    }

    if (normalizedEmail.isNotEmpty && normalizedEmail != (user.email ?? '')) {
      await user.verifyBeforeUpdateEmail(normalizedEmail);
    }

    if (removeAvatar) {
      await _clearAvatar(user.uid);
    } else if (avatarSourcePath != null && avatarSourcePath.trim().isNotEmpty) {
      await _persistAvatar(user.uid, avatarSourcePath);
    }

    await _userDoc(user.uid).set(
      {
        'displayName': normalizedName,
        'email': normalizedEmail,
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

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return user;
  }

  Future<void> _persistAvatar(String uid, String sourcePath) async {
    final prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    final extension = _extensionForPath(sourcePath);
    final savedPath = '${directory.path}${Platform.pathSeparator}avatar_$uid$extension';
    final sourceFile = File(sourcePath);
    final targetFile = File(savedPath);

    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    await sourceFile.copy(savedPath);
    await prefs.setString(_avatarKey(uid), savedPath);
  }

  Future<void> _clearAvatar(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPath = prefs.getString(_avatarKey(uid));
    if (existingPath != null && existingPath.isNotEmpty) {
      final file = File(existingPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove(_avatarKey(uid));
  }

  String _avatarKey(String uid) => 'avatar_path_$uid';

  String _extensionForPath(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) {
      return '.jpg';
    }
    return path.substring(dotIndex);
  }
}
