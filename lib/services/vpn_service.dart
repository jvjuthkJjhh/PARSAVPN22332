import 'dart:async';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import '../models/config_model.dart';

class VpnService {
  VpnService._();
  static final VpnService instance = VpnService._();

  late V2ray _v2ray;
  bool _initialized = false;

  final _statusCtrl = StreamController<V2RayStatus>.broadcast();
  Stream<V2RayStatus> get statusStream => _statusCtrl.stream;

  V2RayConfig? _currentConfig;
  V2RayConfig? get currentConfig => _currentConfig;

  Future<void> initialize() async {
    if (_initialized) return;
    _v2ray = V2ray(
      onStatusChanged: (status) => _statusCtrl.add(status),
    );
    await _v2ray.initialize(
      notificationIconResourceType: "mipmap",
      notificationIconResourceName: "ic_launcher",
    );
    _initialized = true;
  }

  /// اتصال
  Future<bool> connect(V2RayConfig cfg) async {
    try {
      if (!_initialized) await initialize();
      V2RayURL parser = V2ray.parseFromURL(cfg.raw);
      final granted = await _v2ray.requestPermission();
      if (!granted) return false;

      _currentConfig = cfg;

      await _v2ray.startV2Ray(
        remark: cfg.name,
        config: parser.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// قطع اتصال
  Future<void> disconnect() async {
    try {
      await _v2ray.stopV2Ray();
      _currentConfig = null;
    } catch (_) {}
  }

  /// پینگ یه کانفیگ
  Future<int> getServerDelay(String raw) async {
    V2RayURL parser = V2ray.parseFromURL(raw);
    return await _v2ray.getServerDelay(
      config: parser.getFullConfiguration(),
    );
  }

  /// وضعیت
  Future<bool> isRunning() async {
    try {
      return await _v2ray.isRunning();
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _statusCtrl.close();
  }
}
