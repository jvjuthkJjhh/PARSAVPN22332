import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _glow = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _ctrl.forward();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final user = await AuthService.checkAutoLogin();
    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 30),
                    Text(
                      'PARSA VPN',
                      style: GoogleFonts.orbitron(
                        color: AppColors.neon,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppColors.neon.withOpacity(0.8),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: AppColors.neon.withOpacity(0.4),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اتصال امن و پرسرعت',
                      style: GoogleFonts.vazirmatn(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.neon),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.neon.withOpacity(0.3 * _glow.value),
              AppColors.neon.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: AppColors.neon.withOpacity(_glow.value),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neon.withOpacity(0.5 * _glow.value),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'VPN',
            style: GoogleFonts.orbitron(
              color: AppColors.neon,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [
                Shadow(color: AppColors.neon, blurRadius: 15),
                Shadow(color: AppColors.neon, blurRadius: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
