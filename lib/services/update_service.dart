import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/translations.dart';

class UpdateService {
  UpdateService._();

  static final UpdateService instance = UpdateService._();

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_version')
          .get();

      if (!doc.exists || !context.mounted) return;

      final data = doc.data()!;
      final latestVersion = data['latestVersion'] as String?;
      final downloadUrl = data['downloadUrl'] as String?;
      final isMandatory = data['isMandatory'] as bool? ?? false;
      final releaseNotes = data['releaseNotes'] as String?;

      if (latestVersion != null &&
          downloadUrl != null &&
          _isNewerVersion(currentVersion, latestVersion)) {
        _showUpdateDialog(
          context,
          latestVersion: latestVersion,
          downloadUrl: downloadUrl,
          isMandatory: isMandatory,
          releaseNotes: releaseNotes,
        );
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  bool _isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        final c = i < currentParts.length ? currentParts[i] : 0;
        final l = i < latestParts.length ? latestParts[i] : 0;

        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (_) {
      return current != latest;
    }
  }

  void _showUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    required String downloadUrl,
    required bool isMandatory,
    String? releaseNotes,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !isMandatory,
          child: AlertDialog(
            title: Text(tr('Update Available')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'A new version ({version}) is available. Please update to get the latest features and bug fixes.',
                    namedArgs: {'version': latestVersion},
                  ),
                ),
                if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    tr('What is new:'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(releaseNotes),
                ],
              ],
            ),
            actions: [
              if (!isMandatory)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('Later')),
                ),
              FilledButton(
                onPressed: () async {
                  final url = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(tr('Update Now')),
              ),
            ],
          ),
        );
      },
    );
  }
}
