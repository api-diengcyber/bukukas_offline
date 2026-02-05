import 'package:flutter/foundation.dart'; // Wajib import ini untuk kDebugMode
import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static const String _keyEmail = "user_email";
  static const String _keyPass = "user_pass";
  static const String _keyPremium = "is_premium";
  static const String _keyLastBackup = "last_backup";

  static Future<void> saveUserEmail(String value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_keyEmail, value);
  }

  static Future<String> getUserEmail() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_keyEmail) ?? "";
  }

  static Future<void> saveUserPass(String value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_keyPass, value);
  }

  static Future<String> getUserPass() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_keyPass) ?? "";
  }

  static Future<void> savePremiumStatus(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(_keyPremium, value);
  }

  static Future<bool> isPremium() async {
    // MODIFIKASI: Jika aplikasi dijalankan dalam mode debug, otomatis return true
    if (kDebugMode) {
      return true; 
    }
    
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_keyPremium) ?? false;
  }

  static Future<void> saveLastBackup(String value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_keyLastBackup, value);
  }

  static Future<String> getLastBackup() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_keyLastBackup) ?? "Belum pernah";
  }
}