import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/translations.dart';

class UpdateService {
  UpdateService._();

  static final UpdateService instance = UpdateService._();

  bool _checkedThisSession = false;

  Future<void> checkForUpdates(
    BuildContext context, {
    bool force = false,
  }) async {
    if (_checkedThisSession && !force) {
      return;
    }
    _checkedThisSession = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_version')
          .get();

      if (!doc.exists || !context.mounted) return;

      final data = doc.data()!;
      final latestVersion = data['latestVersion'] as String?;
      final latestBuildNumber = data['latestBuildNumber']?.toString() ??
          data['latestBuild']?.toString();
      final downloadUrl = data['downloadUrl'] as String?;
      final isMandatory = data['isMandatory'] as bool? ?? false;
      final releaseNotes = data['releaseNotes'] as String?;

      if (latestVersion != null &&
          downloadUrl != null &&
          isNewerVersion(
            currentVersion: packageInfo.version,
            currentBuildNumber: packageInfo.buildNumber,
            latestVersion: latestVersion,
            latestBuildNumber: latestBuildNumber,
          )) {
        _showUpdateDialog(
          context,
          latestVersion: _displayVersion(latestVersion, latestBuildNumber),
          downloadUrl: downloadUrl,
          isMandatory: isMandatory,
          releaseNotes: releaseNotes,
        );
      }
    } catch (e) {
      _checkedThisSession = false;
      debugPrint('Error checking for updates: $e');
    }
  }

  bool isNewerVersion({
    required String currentVersion,
    String? currentBuildNumber,
    required String latestVersion,
    String? latestBuildNumber,
  }) {
    final current = _AppVersion.parse(
      currentVersion,
      buildNumber: currentBuildNumber,
    );
    final latest = _AppVersion.parse(
      latestVersion,
      buildNumber: latestBuildNumber,
    );

    return latest.compareTo(current) > 0;
  }

  String _displayVersion(String version, String? buildNumber) {
    if (buildNumber == null || buildNumber.trim().isEmpty) {
      return version;
    }
    if (version.contains('+')) {
      return version;
    }
    return '$version+$buildNumber';
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

class _AppVersion implements Comparable<_AppVersion> {
  const _AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
    required this.raw,
  });

  final int major;
  final int minor;
  final int patch;
  final int build;
  final String raw;

  factory _AppVersion.parse(String value, {String? buildNumber}) {
    final trimmed = value.trim();
    final versionAndBuild = trimmed.split('+');
    final versionParts = versionAndBuild.first.split('.');
    final inlineBuild = versionAndBuild.length > 1 ? versionAndBuild[1] : null;

    return _AppVersion(
      major: _part(versionParts, 0),
      minor: _part(versionParts, 1),
      patch: _part(versionParts, 2),
      build: int.tryParse((buildNumber ?? inlineBuild ?? '').trim()) ?? 0,
      raw: trimmed,
    );
  }

  static int _part(List<String> parts, int index) {
    if (index >= parts.length) {
      return 0;
    }
    return int.tryParse(parts[index].trim()) ?? 0;
  }

  @override
  int compareTo(_AppVersion other) {
    final current = [major, minor, patch, build];
    final previous = [other.major, other.minor, other.patch, other.build];

    for (var index = 0; index < current.length; index++) {
      final comparison = current[index].compareTo(previous[index]);
      if (comparison != 0) {
        return comparison;
      }
    }
    return raw.compareTo(other.raw);
  }
}
