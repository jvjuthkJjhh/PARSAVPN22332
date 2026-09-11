import '../models/license_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  // ═══ رمزهای ثابت ═══
  static const String CREATOR_PASSWORD = 'poiiu';
  static const String ADMIN_PASSWORD = 'poiiu';

  // ══════════════ ورود با لایسنس ══════════════

  /// ورود کاربر با کلید لایسنس
  /// برمی‌گرداند: null اگه خطا داشت، در غیر این صورت کاربر
  static Future<AuthResult> loginWithLicense(String key) async {
    key = key.trim().toUpperCase();

    if (key.isEmpty) {
      return AuthResult.fail('لطفاً کلید لایسنس را وارد کنید');
    }

    final licenses = await StorageService.loadLicenses();
    License? found;
    for (final l in licenses) {
      if (l.key.toUpperCase() == key) {
        found = l;
        break;
      }
    }

    if (found == null) {
      return AuthResult.fail('کلید لایسنس نامعتبر است');
    }

    if (found.isExpired) {
      return AuthResult.fail(
        'این کلید منقضی شده است (${found.remainingText})',
      );
    }

    if (!found.isActive) {
      return AuthResult.fail('این کلید غیرفعال شده است');
    }

    await StorageService.saveCurrentLicenseKey(found.key);
    final user = AppUser.withLicense(found.key, found.expiresAt);
    return AuthResult.success(user);
  }

  // ══════════════ ورود سازنده ══════════════

  static Future<AuthResult> loginAsCreator(String password) async {
    if (password != CREATOR_PASSWORD) {
      return AuthResult.fail('رمز سازنده اشتباه است');
    }
    await StorageService.setAdminLoggedIn(true);
    return AuthResult.success(AppUser.creator());
  }

  // ══════════════ ورود مدیر ══════════════

  static Future<AuthResult> loginAsAdmin(String password) async {
    if (password != ADMIN_PASSWORD) {
      return AuthResult.fail('رمز مدیر اشتباه است');
    }
    await StorageService.setAdminLoggedIn(true);
    return AuthResult.success(AppUser.admin());
  }

  // ══════════════ بررسی خودکار ══════════════

  /// بررسی خودکار در زمان باز شدن اپ
  static Future<AppUser?> checkAutoLogin() async {
    final isAdmin = await StorageService.isAdminLoggedIn();
    if (isAdmin) {
      return AppUser.admin();
    }

    final key = await StorageService.loadCurrentLicenseKey();
    if (key == null) return null;

    final licenses = await StorageService.loadLicenses();
    for (final l in licenses) {
      if (l.key == key && l.isValid) {
        return AppUser.withLicense(l.key, l.expiresAt);
      }
    }

    return null;
  }

  // ══════════════ خروج ══════════════

  static Future<void> logout() async {
    await StorageService.saveCurrentLicenseKey(null);
    await StorageService.setAdminLoggedIn(false);
  }

  // ══════════════ اعتبارسنجی کلید ══════════════

  static Future<License?> validateLicense(String key) async {
    final licenses = await StorageService.loadLicenses();
    for (final l in licenses) {
      if (l.key.toUpperCase() == key.toUpperCase() && l.isValid) {
        return l;
      }
    }
    return null;
  }
}

// ══════════════ نتیجه احراز هویت ══════════════

class AuthResult {
  final bool success;
  final String? error;
  final AppUser? user;

  AuthResult({
    required this.success,
    this.error,
    this.user,
  });

  factory AuthResult.success(AppUser user) =>
      AuthResult(success: true, user: user);

  factory AuthResult.fail(String error) =>
      AuthResult(success: false, error: error);
}
