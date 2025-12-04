import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String userId = 'userId';

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(UserPrefs.userId, "688217fd660df33b9a85f42c");
    await prefs.setString(UserPrefs.userId, userId);
  }

  /// Get user ID (returns null if not set)
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(UserPrefs.userId);
  }

  /// Remove user ID (e.g., on logout)
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(UserPrefs.userId);
  }
}
