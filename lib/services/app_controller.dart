import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'profile_service.dart';

class AppController extends ChangeNotifier {
  AppController._();

  static final AppController instance = AppController._();

  ProfileService? _profileService;

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;

  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en';
  UserProfile? _profile;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  UserProfile? get profile => _profile;
  bool get initialized => _initialized;

  ProfileService get _profiles => _profileService ??= ProfileService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _themeModeFromName(prefs.getString(_themeModeKey) ?? 'light');
    _languageCode = _normalizeLanguageCode(
      prefs.getString(_languageCodeKey) ??
          PlatformDispatcher.instance.locale.languageCode,
    );

    _authSubscription ??=
        FirebaseAuth.instance.authStateChanges().listen(_handleAuthChanged);

    await _handleAuthChanged(FirebaseAuth.instance.currentUser);
    _initialized = true;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    await _profiles.ensureProfileForUser(user);
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required int avatarSeed,
    String? avatarSourcePath,
    bool removeAvatar = false,
  }) async {
    final existing = _profile;
    if (existing == null) {
      return;
    }

    _profile = existing.copyWith(
      displayName: displayName.trim().isEmpty
          ? existing.displayName
          : displayName.trim(),
      email: email.trim().isEmpty ? existing.email : email.trim(),
      avatarSeed: avatarSeed,
      clearAvatarPath: removeAvatar,
    );
    notifyListeners();

    await _profiles.updateProfile(
      displayName: displayName,
      email: email,
      avatarSeed: avatarSeed,
      avatarSourcePath: avatarSourcePath,
      removeAvatar: removeAvatar,
    );

    await refreshProfile();
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
    final existing = _profile;
    if (existing == null) {
      if (themeMode != null) {
        _themeMode = _themeModeFromName(themeMode);
        await _persistThemeMode(themeMode);
      }
      if (languageCode != null) {
        _languageCode = _normalizeLanguageCode(languageCode);
        await _persistLanguageCode(_languageCode);
      }
      if (themeMode != null || languageCode != null) {
        notifyListeners();
      }
      return;
    }

    final nextThemeName = themeMode ?? existing.themeModeName;
    _profile = existing.copyWith(
      themeModeName: nextThemeName,
      languageCode: languageCode,
      aiAutoPlanning: aiAutoPlanning,
      smartPrioritization: smartPrioritization,
      smartReminders: smartReminders,
      focusMode: focusMode,
      pushNotifications: pushNotifications,
      dailyDigest: dailyDigest,
      weeklyReport: weeklyReport,
    );

    _themeMode = _themeModeFromName(nextThemeName);
    if (languageCode != null) {
      _languageCode = _normalizeLanguageCode(languageCode);
    }
    await _persistThemeMode(nextThemeName);
    await _persistLanguageCode(_languageCode);
    notifyListeners();

    await _profiles.updatePreferences(
      themeMode: themeMode,
      languageCode: languageCode,
      aiAutoPlanning: aiAutoPlanning,
      smartPrioritization: smartPrioritization,
      smartReminders: smartReminders,
      focusMode: focusMode,
      pushNotifications: pushNotifications,
      dailyDigest: dailyDigest,
      weeklyReport: weeklyReport,
    );
  }

  Future<void> removeAvatar() async {
    final existing = _profile;
    if (existing == null) {
      return;
    }

    _profile = existing.copyWith(clearAvatarPath: true);
    notifyListeners();

    await _profiles.removeAvatar();
    await refreshProfile();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _handleAuthChanged(User? user) async {
    await _profileSubscription?.cancel();
    _profileSubscription = null;

    if (user == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    final initialProfile = await _profiles.ensureProfileForUser(user);
    _profile = initialProfile;
    _themeMode = _themeModeFromName(initialProfile.themeModeName);
    _languageCode = _normalizeLanguageCode(initialProfile.languageCode);
    await _persistThemeMode(initialProfile.themeModeName);
    await _persistLanguageCode(_languageCode);
    notifyListeners();

    _profileSubscription = _profiles.watchProfile(user.uid).listen((
      profile,
    ) async {
      if (profile == null) {
        return;
      }

      _profile = profile;
      final resolvedTheme = _themeModeFromName(profile.themeModeName);
      if (_themeMode != resolvedTheme) {
        _themeMode = resolvedTheme;
        await _persistThemeMode(profile.themeModeName);
      }
      final resolvedLanguage = _normalizeLanguageCode(profile.languageCode);
      if (_languageCode != resolvedLanguage) {
        _languageCode = resolvedLanguage;
        await _persistLanguageCode(_languageCode);
      }
      notifyListeners();
    });
  }

  ThemeMode _themeModeFromName(String name) {
    switch (name) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> _persistThemeMode(String themeModeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeModeName);
  }

  String _normalizeLanguageCode(String value) {
    return value.toLowerCase().startsWith('ru') ? 'ru' : 'en';
  }

  Future<void> _persistLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
}
