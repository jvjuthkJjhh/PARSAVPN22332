import 'dart:async';
import 'package:flutter/material.dart'; 
import 'package:google_fonts/google_fonts.dart';

import '../models/config_model.dart';
import '../models/user_model.dart';
import '../services/config_fetcher.dart';
import '../services/ping_service.dart';
import '../services/storage_service.dart';
import '../services/vpn_service.dart';
import '../theme/colors.dart';
import 'admin_screen.dart';
import 'configs_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _vpn = VpnService.instance;

  List<V2RayConfig> _vipConfigs = [];
  V2RayConfig? _selected;

  bool _loading = false;
  bool _connecting = false;
  bool _connected = false;
  String _statusText = 'قطع';
  String _progressText = '';

  int? _downSpeed;
  int? _upSpeed;
  DateTime? _connectTime;
  Timer? _durationTimer;

  late AnimationController _pulse;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);

    _vpn.initialize();
    _listenStatus();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final configs = await StorageService.loadConfigs();
    if (!mounted) return;
    setState(() {
      _vipConfigs = configs;
      if (configs.isNotEmpty) _selected = configs.first;
    });
  }

  void _listenStatus() {
    _statusSub = _vpn.statusStream.listen((status) {
      if (!mounted) return;
      setState(() {
        if (status.state == V2RayStatus.connected) {
          _connected = true;
          _connecting = false;
          _statusText = 'متصل';
          _connectTime ??= DateTime.now();
          _startDurationTimer();
        } else if (status.state == V2RayStatus.disconnected) {
          _connected = false;
          _connecting = false;
          _statusText = 'قطع';
          _downSpeed = null;
          _upSpeed = null;
          _stopDurationTimer();
        } else if (status.state == V2RayStatus.connecting) {
          _connecting = true;
          _statusText = 'در حال اتصال...';
        }
        _downSpeed = status.downloadSpeed;
        _upSpeed = status.uploadSpeed;
      });
    });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _connectTime = null;
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _pulse.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  // ════════ جستجوی کانفیگ VIP ════════

  Future<void> _searchVipConfigs() async {
    setState(() {
      _loading = true;
      _progressText = 'در حال دریافت...';
      _vipConfigs.clear();
      _selected = null;
    });

    final fetched = await ConfigFetcher.fetchAll(
      onProgress: (done, total) {
        if (mounted) {
          setState(() => _progressText = 'دریافت $done/$total');
        }
      },
    );

    if (!mounted) return;

    if (fetched.isEmpty) {
      setState(() {
        _loading = false;
        _progressText = '';
      });
      _snack('هیچ کانفیگی دریافت نشد');
      return;
    }

    setState(() => _progressText = 'پینگ‌گیری...');

    final pinged = await PingService.pingAll(
      fetched,
      onProgress: (done, total) {
        if (mounted) {
          setState(() => _progressText = 'پینگ $done/$total');
        }
      },
    );

    if (!mounted) return;

    // فقط ۱۰ تای برتر
    final top10 = pinged.take(10).toList();

    // اسم‌گذاری با Parsa VIP
    for (int i = 0; i < top10.length; i++) {
      top10[i] = V2RayConfig(
        raw: top10[i].raw,
        protocol: top10[i].protocol,
        name: 'Parsa VIP ${(i + 1).toString().padLeft(2, '0')}',
        host: top10[i].host,
        port: top10[i].port,
        network: top10[i].network,
        security: top10[i].security,
        tcpPing: top10[i].tcpPing,
        realPing: top10[i].realPing,
      );
    }

    await StorageService.saveConfigs(top10);

    setState(() {
      _vipConfigs = top10;
      _loading = false;
      _progressText = '';
      if (top10.isNotEmpty) _selected = top10.first;
    });

    _snack('۱۰ کانفیگ VIP آماده شد');
  }

  // ════════ اتصال ════════

  Future<void> _toggleConnection() async {
    if (_connecting) return;

    if (_connected) {
      setState(() {
        _connecting = true;
        _statusText = 'در حال قطع...';
      });
      await _vpn.disconnect();
      return;
    }

    if (_selected == null) {
      _snack('اول یک کانفیگ VIP انتخاب کن');
      return;
    }

    setState(() {
      _connecting = true;
      _statusText = 'در حال اتصال...';
    });

    final ok = await _vpn.connect(_selected!);
    if (ok) {
      await StorageService.saveLastConfig(_selected!.raw);
    } else {
      setState(() {
        _connecting = false;
        _statusText = 'خطا در اتصال';
      });
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.vazirmatn()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Duration? get _duration {
    if (_connectTime == null) return null;
    return DateTime.now().difference(_connectTime!);
  }

  String _fmtSpeed(int? bps) {
    if (bps == null) return '0';
    final kb = bps / 1024;
    if (kb < 1024) return kb.toStringAsFixed(0);
    return (kb / 1024).toStringAsFixed(1);
  }

  String _fmtDuration(Duration? d) {
    if (d == null) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color get _btnColor {
    if (_connected) return AppColors.success;
    if (_connecting) return AppColors.warning;
    return AppColors.neon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              _buildConnectButton(),
              const SizedBox(height: 20),
              _buildStatus(),
              const SizedBox(height: 8),
              if (_selected != null) _buildSelectedInfo(),
              const Spacer(),
              if (_connected) _buildSpeedRow(),
              const SizedBox(height: 12),
              _buildBottomCards(),
              const SizedBox(height: 12),
              if (_loading) _buildProgress(),
              _buildSearchButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'VPN',
              style: GoogleFonts.orbitron(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parsa VPN',
                  style: GoogleFonts.orbitron(
                    color: AppColors.neon,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  widget.user.isAdmin
                      ? widget.user.roleName
                      : '${widget.user.remainingDays} روز باقی‌مانده',
                  style: GoogleFonts.vazirmatn(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (widget.user.isAdmin)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings, color: AppColors.neon),
            ),
          IconButton(
            onPressed: _openConfigs,
            icon: const Icon(Icons.list, color: AppColors.neon),
          ),
        ],
      ),
    );
  }

  void _openConfigs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfigsScreen(
          configs: _vipConfigs,
          selected: _selected,
          onSelect: (cfg) {
            setState(() => _selected = cfg);
          },
        ),
      ),
    );
  }

  Widget _buildConnectButton() {
    return GestureDetector(
      onTap: _toggleConnection,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Transform.scale(
          scale: _connected ? _pulse.value : 1.0,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _btnColor.withOpacity(0.25),
                  _btnColor.withOpacity(0.05),
                ],
              ),
              border: Border.all(color: _btnColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _btnColor.withOpacity(0.5),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: _btnColor.withOpacity(0.2),
                  blurRadius: 80,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: _connecting
                  ? const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.power_settings_new,
                      size: 70,
                      color: _btnColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    return Text(
      _statusText,
      style: GoogleFonts.vazirmatn(
        color: _connected ? AppColors.success : AppColors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSelectedInfo() {
    return Text(
      '${_selected!.protocolShort} • ${_selected!.shortName}',
      style: GoogleFonts.vazirmatn(
        color: AppColors.textMuted,
        fontSize: 11,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSpeedRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _speedCard(
              Icons.arrow_downward,
              'دانلود',
              '${_fmtSpeed(_downSpeed)} KB/s',
              AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _speedCard(
              Icons.arrow_upward,
              'آپلود',
              '${_fmtSpeed(_upSpeed)} KB/s',
              AppColors.neon,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _speedCard(
              Icons.timer_outlined,
              'زمان',
              _fmtDuration(_duration),
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _speedCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _infoCard(
              Icons.location_on_outlined,
              'موقعیت شما',
              'ایران',
              '🇮🇷',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _infoCard(
              Icons.speed,
              'کانفیگ فعال',
              _selected?.name ?? 'هیچ',
              _selected?.pingText ?? '✕',
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, String trailing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.neon, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.vazirmatn(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                trailing,
                style: GoogleFonts.vazirmatn(
                  color: AppColors.neon,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        children: [
          const LinearProgressIndicator(
            backgroundColor: AppColors.card,
            color: AppColors.neon,
            minHeight: 3,
          ),
          const SizedBox(height: 6),
          Text(
            _progressText,
            style: GoogleFonts.vazirmatn(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _searchVipConfigs,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              )
            : const Icon(Icons.search, size: 18),
        label: Text(
          _loading ? 'در حال جستجو...' : 'جستجوی کانفیگ VIP',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neon,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
