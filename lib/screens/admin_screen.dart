import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/license_model.dart';
import '../services/auth_service.dart';
import '../services/license_service.dart';
import '../theme/colors.dart';
import 'license_generator_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<License> _licenses = [];
  LicenseStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await LicenseService.getAll();
    final stats = await LicenseService.getStats();
    if (!mounted) return;
    setState(() {
      _licenses = list;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _deleteLicense(String key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'حذف لایسنس',
          style: GoogleFonts.vazirmatn(color: Colors.white),
        ),
        content: Text(
          'مطمئنی می‌خوای کلید "$key" رو حذف کنی؟',
          style: GoogleFonts.vazirmatn(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LicenseService.deleteLicense(key);
      _load();
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'پنل مدیریت',
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neon),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.danger),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neon),
            )
          : RefreshIndicator(
              color: AppColors.neon,
              backgroundColor: AppColors.card,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildGenerateButton(),
                  const SizedBox(height: 24),
                  _buildLicensesHeader(),
                  const SizedBox(height: 8),
                  if (_licenses.isEmpty)
                    _buildEmptyState()
                  else
                    ..._licenses.map(_buildLicenseTile),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow() {
    final s = _stats;
    if (s == null) return const SizedBox();

    return Row(
      children: [
        Expanded(child: _statCard('کل', '${s.total}', AppColors.neon)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('فعال', '${s.active}', AppColors.success)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('منقضی', '${s.expired}', AppColors.danger)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LicenseGeneratorScreen()),
        );
        _load();
      },
      icon: const Icon(Icons.vpn_key, size: 20),
      label: Text(
        'ساخت کلید لایسنس جدید',
        style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildLicensesHeader() {
    return Row(
      children: [
        Text(
          'لایسنس‌ها',
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '${_licenses.length} مورد',
          style: GoogleFonts.vazirmatn(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.key_off_outlined,
              color: AppColors.textDisabled, size: 50),
          const SizedBox(height: 10),
          Text(
            'هنوز لایسنسی ساخته نشده',
            style: GoogleFonts.vazirmatn(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseTile(License l) {
    final isValid = l.isValid;
    final color = isValid ? AppColors.success : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isValid ? Icons.check_circle_outline : Icons.timer_off_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.key,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.isExpired ? 'منقضی شده' : '${l.remainingText} باقی‌مانده',
                  style: GoogleFonts.vazirmatn(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteLicense(l.key),
            icon: const Icon(Icons.delete_outline,
                color: AppColors.danger, size: 20),
          ),
        ],
      ),
    );
  }
}
