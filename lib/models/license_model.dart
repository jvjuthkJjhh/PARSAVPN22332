class License {
  final String key;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int durationDays;
  bool isActive;
  String? usedBy;

  License({
    required this.key,
    required this.createdAt,
    required this.expiresAt,
    required this.durationDays,
    this.isActive = true,
    this.usedBy,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => isActive && !isExpired;

  int get remainingDays {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  int get remainingHours {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inHours % 24;
  }

  String get remainingText {
    if (isExpired) return 'منقضی شده';
    final d = remainingDays;
    final h = remainingHours;
    if (d > 0) return '$d روز و $h ساعت';
    if (h > 0) return '$h ساعت';
    return 'کمتر از یک ساعت';
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'durationDays': durationDays,
        'isActive': isActive,
        'usedBy': usedBy,
      };

  static License fromJson(Map<String, dynamic> json) {
    return License(
      key: json['key'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      durationDays: json['durationDays'] ?? 30,
      isActive: json['isActive'] ?? true,
      usedBy: json['usedBy'],
    );
  }

  /// ساخت کلید تصادفی
  static String generateKey({int length = 16}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();
    int seed = rand;
    for (int i = 0; i < length; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
      buffer.write(chars[seed % chars.length]);
      if ((i + 1) % 4 == 0 && i != length - 1) {
        buffer.write('-');
      }
    }
    return buffer.toString();
  }

  /// ساخت لایسنس جدید
  static License create({required int days}) {
    return License(
      key: generateKey(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: days)),
      durationDays: days,
    );
  }
}
