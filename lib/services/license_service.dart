import '../models/license_model.dart';
import 'storage_service.dart';

class LicenseService {
  /// ساخت کلید جدید
  static Future<License> generateLicense({
    required int days,
    String? customKey,
  }) async {
    final license = customKey != null && customKey.isNotEmpty
        ? License(
            key: customKey.toUpperCase(),
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(Duration(days: days)),
            durationDays: days,
          )
        : License.create(days: days);

    await StorageService.addLicense(license);
    return license;
  }

  /// دریافت همه لایسنس‌ها
  static Future<List<License>> getAll() async {
    return await StorageService.loadLicenses();
  }

  /// حذف لایسنس
  static Future<void> deleteLicense(String key) async {
    await StorageService.removeLicense(key);
  }

  /// پاک کردن همه لایسنس‌ها
  static Future<void> clearAll() async {
    await StorageService.saveLicenses([]);
  }

  /// آمار
  static Future<LicenseStats> getStats() async {
    final list = await StorageService.loadLicenses();
    int active = 0;
    int expired = 0;

    for (final l in list) {
      if (l.isValid) {
        active++;
      } else {
        expired++;
      }
    }

    return LicenseStats(
      total: list.length,
      active: active,
      expired: expired,
    );
  }

  /// تولید چند کلید با هم
  static Future<List<License>> generateBulk({
    required int days,
    required int count,
  }) async {
    final result = <License>[];
    for (int i = 0; i < count; i++) {
      final license = License.create(days: days);
      await StorageService.addLicense(license);
      result.add(license);
    }
    return result;
  }
}

class LicenseStats {
  final int total;
  final int active;
  final int expired;

  LicenseStats({
    required this.total,
    required this.active,
    required this.expired,
  });
}
