import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/config_model.dart';
import '../theme/colors.dart';

class ConfigsScreen extends StatefulWidget {
  final List<V2RayConfig> configs;
  final V2RayConfig? selected;
  final Function(V2RayConfig) onSelect;

  const ConfigsScreen({
    super.key,
    required this.configs,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  late List<V2RayConfig> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.configs);
  }

  Color _protocolColor(String p) {
    switch (p) {
      case 'VLESS':
        return AppColors.vless;
      case 'VMess':
        return AppColors.vmess;
      case 'Trojan':
        return AppColors.trojan;
      case 'Shadowsocks':
        return AppColors.shadowsocks;
      default:
        return Colors.grey;
    }
  }

  Color _pingColor(int? ping) {
    if (ping == null) return AppColors.danger;
    if (ping < 200) return AppColors.success;
    if (ping < 500) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'کانفیگ‌های Parsa VIP',
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
      body: _list.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _list.length,
              itemBuilder: (_, i) => _buildTile(_list[i], i),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dns_outlined, color: AppColors.textDisabled, size: 60),
          const SizedBox(height: 12),
          Text(
            'هنوز کانفیگی نداری',
            style: GoogleFonts.vazirmatn(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'از صفحه اصلی «جستجوی کانفیگ VIP» رو ب
