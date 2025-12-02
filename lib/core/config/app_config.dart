import 'package:flutter/foundation.dart';

class AppConfig {
  // Base URL from dart-define or default
  // Production API (deployed): http://3.72.254.198/v1
  // Local Laravel Herd (Android emulator):
  //   - Herd default domain: http://maawa_project.test/v1 (desktop browser only)
  //   - Emulator localhost alias: http://10.0.2.2/v1
  //   - Wi-Fi IP fallback: run `ipconfig`, use http://YOUR_WIFI_IP/v1
  //   - Example: flutter run --dart-define=API_BASE_URL=http://10.0.2.2/v1
  static String get baseUrl {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://3.72.254.198/v1', // Production backend
    );
    if (kDebugMode) {
      debugPrint('AppConfig.baseUrl: $baseUrl');
      debugPrint('🌐 Default (deployed) backend: http://3.72.254.198/v1');
      debugPrint('🧪 Local dev options:');
      debugPrint('   • http://10.0.2.2/v1 (emulator → host localhost)');
      debugPrint('   • http://<your_wifi_ip>/v1 (real device on same network)');
      debugPrint(
        '     e.g. flutter run --dart-define=API_BASE_URL=http://10.0.2.2/v1',
      );
    }
    return baseUrl;
  }

  static String get apiOrigin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  static String resolveAssetUrl(String path) {
    if (path.isEmpty || path.startsWith('http')) {
      return path;
    }
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$apiOrigin$normalizedPath';
  }

  // Environment
  static bool get isDevelopment {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'dev';
  }

  static bool get isProduction {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod';
  }

  // Mock Mode - Set to true to bypass API calls for development
  static const bool useMockAuth = false;
}

