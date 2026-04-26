import 'package:aria_productivity_app/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateService', () {
    test('detects newer semantic version', () {
      expect(
        UpdateService.instance.isNewerVersion(
          currentVersion: '1.0.1',
          currentBuildNumber: '2',
          latestVersion: '1.0.2',
          latestBuildNumber: '1',
        ),
        isTrue,
      );
    });

    test('detects newer build with the same semantic version', () {
      expect(
        UpdateService.instance.isNewerVersion(
          currentVersion: '1.0.1',
          currentBuildNumber: '2',
          latestVersion: '1.0.1',
          latestBuildNumber: '3',
        ),
        isTrue,
      );
    });

    test('does not downgrade when latest build is older', () {
      expect(
        UpdateService.instance.isNewerVersion(
          currentVersion: '1.0.1',
          currentBuildNumber: '3',
          latestVersion: '1.0.1',
          latestBuildNumber: '2',
        ),
        isFalse,
      );
    });

    test('supports inline build numbers', () {
      expect(
        UpdateService.instance.isNewerVersion(
          currentVersion: '1.0.1+2',
          latestVersion: '1.0.1+3',
        ),
        isTrue,
      );
    });
  });
}
