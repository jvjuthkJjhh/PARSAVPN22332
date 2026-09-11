import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══ پس‌زمینه ═══
  static const Color bg = Color(0xFF000000);
  static const Color bgDark = Color(0xFF0A0E14);
  static const Color card = Color(0xFF11151C);
  static const Color cardLight = Color(0xFF1A1F29);
  static const Color cardHover = Color(0xFF202632);
  static const Color divider = Color(0xFF1F252F);
  static const Color border = Color(0xFF232A35);

  // ═══ نئون آبی (رنگ اصلی) ═══
  static const Color neon = Color(0xFF00D4FF);
  static const Color neonDark = Color(0xFF0099CC);
  static const Color neonLight = Color(0xFF33DDFF);
  static const Color neonGlow = Color(0x6600D4FF);
  static const Color neonSoft = Color(0x2200D4FF);
  static const Color neonFaint = Color(0x1100D4FF);

  // ═══ وضعیت‌ها ═══
  static const Color success = Color(0xFF00E676);
  static const Color successDark = Color(0xFF00A653);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // ═══ پروتکل‌ها ═══
  static const Color vless = Color(0xFF42A5F5);
  static const Color vmess = Color(0xFFAB47BC);
  static const Color trojan = Color(0xFFFF7043);
  static const Color shadowsocks = Color(0xFF26A69A);

  // ═══ متن ═══
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C4);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF3F4854);

  // ═══ گرادیانت‌ها ═══
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF4A8EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradientV = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF0A0E14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
