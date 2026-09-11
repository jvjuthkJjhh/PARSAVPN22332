enum UserRole { guest, user, admin, creator }

class AppUser {
  final String id;
  final UserRole role;
  final String? licenseKey;
  final DateTime? loginAt;
  final DateTime? licenseExpiresAt;

  AppUser({
    required this.id,
    required this.role,
    this.licenseKey,
    this.loginAt,
    this.licenseExpiresAt,
  });

  bool get isAdmin => role == UserRole.admin || role == UserRole.creator;

  bool get isCreator => role == UserRole.creator;

  bool get hasValidLicense {
    if (isAdmin) return true;
    if (licenseExpiresAt == null) return false;
    return DateTime.now().isBefore(licenseExpiresAt!);
  }

  int get remainingDays {
    if (isAdmin) return 999999;
    if (licenseExpiresAt == null) return 0;
    final diff = licenseExpiresAt!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get roleName {
    switch (role) {
      case UserRole.creator:
        return 'سازنده';
      case UserRole.admin:
        return 'مدیر';
      case UserRole.user:
        return 'کاربر';
      default:
        return 'مهمان';
    }
  }

  static AppUser guest() => AppUser(id: 'guest', role: UserRole.guest);

  static AppUser admin() => AppUser(
        id: 'admin',
        role: UserRole.admin,
        loginAt: DateTime.now(),
      );

  static AppUser creator() => AppUser(
        id: 'creator',
        role: UserRole.creator,
        loginAt: DateTime.now(),
      );

  static AppUser withLicense(String key, DateTime expires) => AppUser(
        id: key,
        role: UserRole.user,
        licenseKey: key,
        loginAt: DateTime.now(),
        licenseExpiresAt: expires,
      );
}
