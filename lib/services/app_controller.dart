import 'dart:async';
import 'dart:typed_data';
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
    Uint8List? avatarBytes,
    bool removeAvatar = false,
  }) async {
    final existing = _profile;
    if (existing == null) {
      return;
    }

    final requestedEmail = email.trim();
    final isEmailChange =
        requestedEmail.isNotEmpty && requestedEmail != existing.email;

    _profile = existing.copyWith(
      displayName: displayName.trim().isEmpty
          ? existing.displayName
          : displayName.trim(),
      email: isEmailChange || requestedEmail.isEmpty
          ? existing.email
          : requestedEmail,
      avatarSeed: avatarSeed,
      localAvatarBytes: avatarBytes,
      clearAvatarPath: removeAvatar,
      clearAvatarBytes: removeAvatar,
    );
    notifyListeners();

    await _profiles.updateProfile(
      displayName: displayName,
      email: email,
      avatarSeed: avatarSeed,
      avatarSourcePath: avatarSourcePath,
      avatarBytes: avatarBytes,
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

  Future<void> updateSubscription(String planName) async {
    final existing = _profile;
    if (existing == null) {
      return;
    }

    final now = DateTime.now();
    final normalizedPlan = _normalizePlanName(planName);
    final isFree = normalizedPlan == 'Free';
    final startedAt = isFree ? null : now;
    final renewsAt = isFree ? null : DateTime(now.year, now.month + 1, now.day);
    final receiptId = isFree
        ? null
        : 'aria-${normalizedPlan.toLowerCase()}-${now.millisecondsSinceEpoch}';
    final status = isFree ? 'free' : 'active';

    _profile = existing.copyWith(
      planName: normalizedPlan,
      subscriptionStatus: status,
      subscriptionStartedAt: startedAt,
      subscriptionRenewsAt: renewsAt,
      subscriptionReceiptId: receiptId,
      clearSubscriptionDates: isFree,
    );
    notifyListeners();

    await _profiles.updateSubscription(
      planName: normalizedPlan,
      status: status,
      startedAt: startedAt,
      renewsAt: renewsAt,
      receiptId: receiptId,
    );
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

  String _normalizePlanName(String name) {
    switch (name.toLowerCase()) {
      case 'business':
        return 'Business';
      case 'pro':
        return 'Pro';
      case 'free':
      default:
        return 'Free';
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
