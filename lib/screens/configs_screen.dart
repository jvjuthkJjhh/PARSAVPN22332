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
            'از صفحه اصلی «جستجوی کانفیگ VIP» رو بزن',
            style: GoogleFonts.vazirmatn(
              color: AppColors.textDisabled,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(V2RayConfig c, int index) {
    final isSelected = widget.selected?.raw == c.raw;
    final ping = c.bestPing;

    return GestureDetector(
      onTap: () {
        widget.onSelect(c);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonSoft : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.neon : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neon.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _protocolColor(c.protocol).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  c.protocolShort,
                  style: GoogleFonts.poppins(
                    color: _protocolColor(c.protocol),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.protocol,
                    style: GoogleFonts.vazirmatn(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ping == null ? '✕' : '$ping',
                  style: GoogleFonts.poppins(
                    color: _pingColor(ping),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'ms',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: AppColors.neon, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
