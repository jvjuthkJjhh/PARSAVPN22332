import 'dart:async';
import '../models/config_model.dart';

class VpnStatus {
  final String state;
  final int downloadSpeed;
  final int uploadSpeed;
  VpnStatus(this.state, this.downloadSpeed, this.uploadSpeed);
}

class VpnService {
  VpnService._();
  static final VpnService instance = VpnService._();

  final _statusCtrl = StreamController<VpnStatus>.broadcast();
  Stream<VpnStatus> get statusStream => _statusCtrl.stream;

  V2RayConfig? _currentConfig;
  V2RayConfig? get currentConfig => _currentConfig;

  Future<void> initialize() async {}

  Future<bool> connect(V2RayConfig cfg) async {
    _currentConfig = cfg;
    _statusCtrl.add(VpnStatus('connecting', 0, 0));
    await Future.delayed(const Duration(seconds: 2));
    _statusCtrl.add(VpnStatus('connected', 1500000, 300000));
    return true;
  }

  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _statusCtrl.add(VpnStatus('disconnected', 0, 0));
    _currentConfig = null;
  }

  Future<int> getServerDelay(String raw) async => 120;

  Future<bool> isRunning() async => false;

  void dispose() => _statusCtrl.close();
}
