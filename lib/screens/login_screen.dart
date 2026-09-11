import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _licenseCtrl = TextEditingController();
  final _adminCtrl = TextEditingController();

  bool _showAdminField = false;
  bool _loading = false;
  bool _obscureAdmin = true;
  String? _error;

  Future<void> _loginWithLicense() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.loginWithLicense(_licenseCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success && result.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result.user!)),
      );
    } else {
      setState(() => _error = result.error);
    }
  }

  Future<void> _loginAsAdmin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.loginAsAdmin(_adminCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success && result.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result.user!)),
      );
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  void dispose() {
    _licenseCtrl.dispose();
    _adminCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 50),
                if (_error != null) _buildError(),
                _buildLicenseField(),
                const SizedBox(height: 16),
                _buildLoginButton(),
                const SizedBox(height: 30),
                _buildAdminToggle(),
                if (_showAdminField) ...[
                  const SizedBox(height: 20),
                  _buildAdminField(),
                  const SizedBox(height: 16),
                  _buildAdminLoginButton(),
                ],
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neon, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neon.withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'VPN',
              style: GoogleFonts.orbitron(
                color: AppColors.neon,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: AppColors.neon, blurRadius: 12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ورود به پارسا VPN',
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'برای ادامه، کلید لایسنس خود را وارد کنید',
          style: GoogleFonts.vazirmatn(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error ?? '',
              style: GoogleFonts.vazirmatn(
                color: AppColors.danger,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'کلید لایسنس',
          style: GoogleFonts.vazirmatn(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _licenseCtrl,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.orbitron(
            color: AppColors.neon,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: 'XXXX-XXXX-XXXX-XXXX',
            hintStyle: GoogleFonts.orbitron(
              color: AppColors.textMuted,
              fontSize: 14,
              letterSpacing: 2,
            ),
            prefixIcon: const Icon(Icons.vpn_key_outlined,
                color: AppColors.neon, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _loginWithLicense,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
          : Text(
              'ورود',
              style: GoogleFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Widget _buildAdminToggle() {
    return TextButton(
      onPressed: () => setState(() => _showAdminField = !_showAdminField),
      child: Text(
        _showAdminField ? '─ بستن ورود مدیران ─' : '─ ورود مدیران ─',
        style: GoogleFonts.vazirmatn(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAdminField() {
    return TextField(
      controller: _adminCtrl,
      textAlign: TextAlign.center,
      obscureText: _obscureAdmin,
      style: GoogleFonts.orbitron(
        color: AppColors.neon,
        fontSize: 14,
        letterSpacing: 2,
      ),
      decoration: InputDecoration(
        hintText: '••••••',
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.admin_panel_settings_outlined,
            color: AppColors.neon, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureAdmin ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted,
            size: 18,
          ),
          onPressed: () => setState(() => _obscureAdmin = !_obscureAdmin),
        ),
      ),
    );
  }

  Widget _buildAdminLoginButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _loginAsAdmin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.neon,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.neon),
        ),
        elevation: 0,
      ),
      child: Text(
        'ورود مدیر',
        style: GoogleFonts.vazirmatn(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Parsa VPN v1.0.0',
      textAlign: TextAlign.center,
      style: GoogleFonts.orbitron(
        color: AppColors.textDisabled,
        fontSize: 10,
        letterSpacing: 2,
      ),
    );
  }
}
