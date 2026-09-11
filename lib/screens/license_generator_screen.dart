import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/license_model.dart';
import '../services/license_service.dart';
import '../theme/colors.dart';

class LicenseGeneratorScreen extends StatefulWidget {
  const LicenseGeneratorScreen({super.key});

  @override
  State<LicenseGeneratorScreen> createState() => _LicenseGeneratorScreenState();
}

class _LicenseGeneratorScreenState extends State<LicenseGeneratorScreen> {
  int _selectedDays = 30;
  bool _generating = false;
  License? _generated;

  final List<int> _dayOptions = [1, 7, 30, 60, 90, 180, 365];

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _generated = null;
    });

    final lic = await LicenseService.generateLicense(days: _selectedDays);

    if (!mounted) return;
    setState(() {
      _generating = false;
      _generated = lic;
    });
  }

  void _copyKey() {
    if (_generated == null) return;
    Clipboard.setData(ClipboardData(text: _generated!.key));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'کلید کپی شد',
          style: GoogleFonts.vazirmatn(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'ساخت کلید لایسنس',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildDaysSection(),
            const SizedBox(height: 30),
            _buildGenerateButton(),
            const SizedBox(height: 30),
            if (_generated != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neon.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.vpn_key, color: AppColors.neon, size: 40),
          const SizedBox(height: 12),
          Text(
            'ساخت کلید لایسنس',
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'یک کلید با اعتبار مشخص بساز و به کاربر بده',
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مدت اعتبار (روز)',
          style: GoogleFonts.vazirmatn(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dayOptions.map((d) {
            final isSelected = d == _selectedDays;
            return GestureDetector(
              onTap: () => setState(() => _selectedDays = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neon : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.neon : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neon.withOpacity(0.4),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '$d روز',
                  style: GoogleFonts.orbitron(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _generating ? null : _generate,
      icon: _generating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
          : const Icon(Icons.auto_awesome, size: 20),
      label: Text(
        _generating ? 'در حال ساخت...' : 'ساخت کلید',
        style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildResult() {
    final lic = _generated!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              const SizedBox(width: 10),
              Text(
                'کلید ساخته شد!',
                style: GoogleFonts.vazirmatn(
                  color: AppColors.success,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neon.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'کلید لایسنس',
                  style: GoogleFonts.vazirmatn(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  lic.key,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: AppColors.neon,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: AppColors.neon.withOpacity(0.6),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'اعتبار: ${lic.durationDays} روز',
                  style: GoogleFonts.vazirmatn(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'انقضا: ${_formatDate(lic.expiresAt)}',
                  style: GoogleFonts.vazirmatn(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyKey,
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(
                    'کپی',
                    style: GoogleFonts.vazirmatn(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neon,
                    side: const BorderSide(color: AppColors.neon),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(
                    'کلید جدید',
                    style: GoogleFonts.vazirmatn(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}
