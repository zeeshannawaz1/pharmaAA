import 'package:firebase_database/firebase_database.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for checking app updates from Firebase Realtime Database
class AppUpdateService {
  static const String _databaseUrl = 'https://pkdriver-and-default-rtdb.firebaseio.com';
  static const String _cachedForceUpdateKey = 'cached_force_update';
  static const String _cachedAppUpdatesKey = 'cached_app_updates';
  static const String _cachedBlockedVersionsKey = 'cached_blocked_versions';
  static const String _lastUpdateCheckKey = 'last_update_check_timestamp';
  
  /// Check if app updates are available
  /// Returns true if updates are available, false otherwise
  static Future<bool> checkAppUpdates() async {
    try {
      final ref = FirebaseDatabase.instance.refFromURL('$_databaseUrl/app_updates');
      final snapshot = await ref.get();
      
      bool value = false;
      if (snapshot.exists) {
        if (snapshot.value is bool) {
          value = snapshot.value as bool;
        } else if (snapshot.value is int) {
          value = (snapshot.value as int) == 1;
        } else if (snapshot.value is String) {
          value = (snapshot.value as String).toLowerCase() == 'true';
        }
      }
      
      // Cache the value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cachedAppUpdatesKey, value);
      await prefs.setInt(_lastUpdateCheckKey, DateTime.now().millisecondsSinceEpoch);
      
      return value;
    } catch (e) {
      print('Error checking app updates: $e');
      // Return cached value if available
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cachedAppUpdatesKey) ?? false;
    }
  }

  /// Get blocked versions from Firebase
  /// Returns list of blocked version numbers (e.g., ["1", "2"])
  static Future<List<String>> getBlockedVersions() async {
    try {
      final ref = FirebaseDatabase.instance.refFromURL('$_databaseUrl/blocked_versions');
      final snapshot = await ref.get();
      
      List<String> blockedVersions = [];
      
      if (snapshot.exists) {
        if (snapshot.value is List) {
          // Handle array format: ["1", "2", "3"]
          final list = snapshot.value as List;
          blockedVersions = list.map((v) => v.toString().trim()).toList();
        } else if (snapshot.value is String) {
          // Handle comma-separated string: "1,2,3" or "1, 2, 3"
          final str = snapshot.value as String;
          blockedVersions = str.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList();
        } else if (snapshot.value is int) {
          // Handle single number: 1
          blockedVersions = [snapshot.value.toString()];
        }
      }
      
      // Cache the blocked versions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_cachedBlockedVersionsKey, blockedVersions);
      await prefs.setInt(_lastUpdateCheckKey, DateTime.now().millisecondsSinceEpoch);
      
      return blockedVersions;
    } catch (e) {
      print('Error getting blocked versions: $e');
      // Return cached value if available
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_cachedBlockedVersionsKey) ?? [];
    }
  }

  /// Check if current app version is blocked
  /// Returns true if current version is in the blocked list
  static Future<bool> isCurrentVersionBlocked() async {
    try {
      // Get current app version
      final versionInfo = await getAppVersionInfo();
      final currentBuildNumber = versionInfo.buildNumber;
      final currentVersionName = versionInfo.version;
      
      // Get blocked versions from Firebase
      final blockedVersions = await getBlockedVersions();
      
      if (blockedVersions.isEmpty) {
        return false; // No versions blocked
      }
      
      // Check if current build number is blocked
      if (blockedVersions.contains(currentBuildNumber)) {
        print('Current build number $currentBuildNumber is blocked');
        return true;
      }
      
      // Also check version name (e.g., "1.0.0")
      // Extract major version number from version name
      final majorVersion = _extractMajorVersion(currentVersionName);
      if (majorVersion != null && blockedVersions.contains(majorVersion)) {
        print('Current version $currentVersionName (major: $majorVersion) is blocked');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking if version is blocked: $e');
      // On error, check cached blocked versions
      return await _isCurrentVersionBlockedFromCache();
    }
  }

  /// Check if current version is blocked using cached data (works offline)
  static Future<bool> _isCurrentVersionBlockedFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedVersions = prefs.getStringList(_cachedBlockedVersionsKey) ?? [];
      
      if (blockedVersions.isEmpty) {
        return false;
      }
      
      final versionInfo = await getAppVersionInfo();
      final currentBuildNumber = versionInfo.buildNumber;
      final currentVersionName = versionInfo.version;
      
      // Check build number
      if (blockedVersions.contains(currentBuildNumber)) {
        return true;
      }
      
      // Check major version
      final majorVersion = _extractMajorVersion(currentVersionName);
      if (majorVersion != null && blockedVersions.contains(majorVersion)) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking cached blocked versions: $e');
      return false;
    }
  }

  /// Extract major version number from version string
  /// "1.0.0" -> "1", "2.3.4" -> "2"
  static String? _extractMajorVersion(String version) {
    try {
      final parts = version.split('.');
      if (parts.isNotEmpty) {
        return parts[0].trim();
      }
    } catch (e) {
      print('Error extracting major version: $e');
    }
    return null;
  }

  /// Check if force update is required
  /// This now checks version-based blocking first
  static Future<bool> checkForceUpdate() async {
    try {
      // FIRST: Check if current version is blocked
      final isBlocked = await isCurrentVersionBlocked();
      if (isBlocked) {
        // Cache that this version is blocked
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_cachedForceUpdateKey, true);
        await prefs.setInt(_lastUpdateCheckKey, DateTime.now().millisecondsSinceEpoch);
        return true;
      }
      
      // SECOND: Check general force_update flag (for all versions)
      final ref = FirebaseDatabase.instance.refFromURL('$_databaseUrl/force_update');
      final snapshot = await ref.get();
      
      bool value = false;
      if (snapshot.exists) {
        if (snapshot.value is bool) {
          value = snapshot.value as bool;
        } else if (snapshot.value is int) {
          value = (snapshot.value as int) == 1;
        } else if (snapshot.value is String) {
          value = (snapshot.value as String).toLowerCase() == 'true';
        }
      }
      
      // Cache the value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cachedForceUpdateKey, value);
      await prefs.setInt(_lastUpdateCheckKey, DateTime.now().millisecondsSinceEpoch);
      
      return value;
    } catch (e) {
      print('Error checking force update: $e');
      // Return cached value - this is critical for offline blocking
      return await getCachedForceUpdate();
    }
  }

  /// Get cached force update status (works offline)
  /// This is the method that should be checked FIRST on app startup
  static Future<bool> getCachedForceUpdate() async {
    try {
      // First check if current version is blocked (from cache)
      final isBlockedFromCache = await _isCurrentVersionBlockedFromCache();
      if (isBlockedFromCache) {
        return true; // Version is blocked
      }
      
      // Then check general force_update flag
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cachedForceUpdateKey) ?? false;
    } catch (e) {
      print('Error getting cached force update: $e');
      return false;
    }
  }

  /// Get cached app updates status (works offline)
  static Future<bool> getCachedAppUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cachedAppUpdatesKey) ?? false;
    } catch (e) {
      print('Error getting cached app updates: $e');
      return false;
    }
  }

  /// Clear cached update status (use when update is completed)
  static Future<void> clearCachedUpdateStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedForceUpdateKey);
      await prefs.remove(_cachedAppUpdatesKey);
      await prefs.remove(_cachedBlockedVersionsKey);
      await prefs.remove(_lastUpdateCheckKey);
    } catch (e) {
      print('Error clearing cached update status: $e');
    }
  }

  /// Get app version information
  static Future<AppVersionInfo> getAppVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return AppVersionInfo(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
      );
    } catch (e) {
      print('Error getting app version info: $e');
      return AppVersionInfo(
        version: '1.0.0',
        buildNumber: '1',
        packageName: 'com.zeework.aadist',
      );
    }
  }

  /// Get minimum required version from Firebase (optional)
  static Future<String?> getMinimumRequiredVersion() async {
    try {
      final ref = FirebaseDatabase.instance.refFromURL('$_databaseUrl/minimum_version');
      final snapshot = await ref.get();
      
      if (snapshot.exists && snapshot.value is String) {
        return snapshot.value as String;
      }
    } catch (e) {
      print('Error getting minimum version: $e');
    }
    return null;
  }
}

/// App version information model
class AppVersionInfo {
  final String version;
  final String buildNumber;
  final String packageName;

  AppVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  String get fullVersion => '$version+$buildNumber';
}

