import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/config_model.dart';
import '../models/license_model.dart';

class StorageService {
  static const _keyConfigs = 'parsa_configs';
  static const _keyFavorites = 'parsa_favorites';
  static const _keyLicenses = 'parsa_licenses';
  static const _keyLastConfig = 'parsa_last_config';
  static const _keyCurrentLicense = 'parsa_current_license';
  static const _keyIsAdminLoggedIn = 'parsa_admin_logged_in';

  // ══════════════ کانفیگ‌ها ══════════════

  static Future<List<V2RayConfig>> loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyConfigs) ?? [];
    final configs = <V2RayConfig>[];
    for (final s in list) {
      try {
        final json = jsonDecode(s) as Map<String, dynamic>;
        final cfg = V2RayConfig.fromJson(json);
        if (cfg != null) configs.add(cfg);
      } catch (_) {}
    }
    return configs;
  }

  static Future<void> saveConfigs(List<V2RayConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = configs.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_keyConfigs, list);
  }

  static Future<void> clearConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyConfigs);
  }

  // ══════════════ علاقه‌مندی‌ها ══════════════

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  static Future<void> toggleFavorite(String raw) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyFavorites) ?? [];
    if (list.contains(raw)) {
      list.remove(raw);
    } else {
      list.add(raw);
    }
    await prefs.setStringList(_keyFavorites, list);
  }

  // ══════════════ آخرین کانفیگ ══════════════

  static Future<String?> loadLastConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastConfig);
  }

  static Future<void> saveLastConfig(String raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastConfig, raw);
  }

  // ══════════════ لایسنس‌ها ══════════════

  static Future<List<License>> loadLicenses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLicenses) ?? [];
    final licenses = <License>[];
    for (final s in list) {
      try {
        final json = jsonDecode(s) as Map<String, dynamic>;
        licenses.add(License.fromJson(json));
      } catch (_) {}
    }
    return licenses;
  }

  static Future<void> saveLicenses(List<License> licenses) async {
    final prefs = await SharedPreferences.getInstance();
    final list = licenses.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList(_keyLicenses, list);
  }

  static Future<void> addLicense(License license) async {
    final list = await loadLicenses();
    list.add(license);
    await saveLicenses(list);
  }

  static Future<void> removeLicense(String key) async {
    final list = await loadLicenses();
    list.removeWhere((l) => l.key == key);
    await saveLicenses(list);
  }

  // ══════════════ لایسنس فعال ══════════════

  static Future<String?> loadCurrentLicenseKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentLicense);
  }

  static Future<void> saveCurrentLicenseKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == null) {
      await prefs.remove(_keyCurrentLicense);
    } else {
      await prefs.setString(_keyCurrentLicense, key);
    }
  }

  // ══════════════ ورود مدیر ══════════════

  static Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsAdminLoggedIn) ?? false;
  }

  static Future<void> setAdminLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAdminLoggedIn, value);
  }

  // ══════════════ پاک کردن همه ══════════════

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
