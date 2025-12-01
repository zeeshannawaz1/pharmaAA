import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  
  // Hardcoded credentials for admin
  static const String _adminUsername = 'admin';
  static const String _adminPassword = 'pass';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user name
  static Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'User';
  }

  // Login with credentials
  static Future<bool> login(String username, String password) async {
    String? userId;
    
    if (username == _adminUsername && password == _adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userNameKey, 'Admin');
      userId = 'Admin';
    }
    // Add support for admin1/admin9
    else if (username == 'admin1' && password == 'admin9') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userNameKey, 'Admin1');
      userId = 'Admin1';
    }
    // Add support for shaniji/pharma (super user)
    else if (username == 'shaniji' && password == 'pharma') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userNameKey, 'Shaniji');
      userId = 'Shaniji';
    }
    else {
      return false;
    }

    // Automatically start location tracking for the logged-in user
    if (userId != null) {
      try {
        await LocationService.startAutomaticLocationTracking(userId);
        // print('✅ Automatic location tracking started for user: $userId');
      } catch (e) {
        print('❌ Error starting automatic location tracking: $e');
      }
    }

    return true;
  }

  // Logout
  static Future<void> logout() async {
    // Stop location tracking before logout
    try {
      await LocationService.stopLocationTracking();
              // print('✅ Location tracking stopped on logout');
    } catch (e) {
      print('❌ Error stopping location tracking: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userNameKey);
  }

  // Initialize location tracking for existing logged-in user
  static Future<void> initializeLocationTracking() async {
    final userIsLoggedIn = await isLoggedIn();
    if (userIsLoggedIn) {
      final userId = await getCurrentUserName();
      try {
        await LocationService.startAutomaticLocationTracking(userId);
        // print('✅ Location tracking initialized for existing user: $userId');
      } catch (e) {
        print('❌ Error initializing location tracking: $e');
      }
    }
  }
} 
