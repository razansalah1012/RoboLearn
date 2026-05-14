import 'package:flutter/foundation.dart';

class TestDataSeeder {
  /// Fresh Start: No hardcoded data.
  /// New users should register via the app's Sign Up screen.
  static Future<void> seedAll() async {
    if (!kDebugMode) return;
    debugPrint("System: Fresh start mode. No hardcoded data seeded.");
  }
}
