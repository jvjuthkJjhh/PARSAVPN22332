import 'dart:io';
import '../models/config_model.dart';

class PingService {
  static Future<int?> tcpPing(String host, int port) async {
    if (host.isEmpty || port == 0) return null;
    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      sw.stop();
      return sw.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> realPing(V2RayConfig cfg) async {
    return await tcpPing(cfg.host, cfg.port);
  }

  static Future<List<V2RayConfig>> pingAll(
    List<V2RayConfig> configs, {
    int tcpConcurrency = 40,
    int realConcurrency = 10,
    void Function(int done, int total)? onProgress,
  }) async {
    final List<V2RayConfig> result = [];

    for (int i = 0; i < configs.length; i += tcpConcurrency) {
      final chunk = configs.sublist(
        i,
        (i + tcpConcurrency > configs.length)
            ? configs.length
            : i + tcpConcurrency,
      );
      await Future.wait(chunk.map((c) async {
        c.tcpPing = await tcpPing(c.host, c.port);
        c.realPing = c.tcpPing;
      }));
      result.addAll(chunk.where((c) => c.tcpPing != null));
      onProgress?.call(i + chunk.length, configs.length);
    }

    result.sort((a, b) => (a.tcpPing ?? 99999).compareTo(b.tcpPing ?? 99999));
    return result;
  }

  static Future<V2RayConfig> pingOne(V2RayConfig cfg) async {
    cfg.tcpPing = await tcpPing(cfg.host, cfg.port);
    cfg.realPing = cfg.tcpPing;
    return cfg;
  }
}
