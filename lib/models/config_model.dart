import 'dart:convert';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';

class V2RayConfig {
  final String raw;
  final String protocol;
  final String name;
  final String host;
  final int port;
  final String? network;
  final String? security;

  int? tcpPing;
  int? realPing;
  bool isFavorite;
  DateTime? lastUsed;
  int usedCount;

  V2RayConfig({
    required this.raw,
    required this.protocol,
    required this.name,
    required this.host,
    required this.port,
    this.network,
    this.security,
    this.tcpPing,
    this.realPing,
    this.isFavorite = false,
    this.lastUsed,
    this.usedCount = 0,
  });

  static V2RayConfig? fromRaw(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return null;

    try {
      V2RayURL parser = V2ray.parseFromURL(raw);
      String protocol = _detectProtocol(raw);
      if (protocol == 'Unknown') return null;

      String host = '';
      int port = 0;
      String? network;
      String? security;

      try {
        final fullConfig = jsonDecode(parser.getFullConfiguration());
        final outbounds = fullConfig['outbounds'] as List?;
        if (outbounds != null) {
          for (final ob in outbounds) {
            final settings = ob['settings'];
            if (settings == null) continue;
            if (settings['vnext'] != null &&
                (settings['vnext'] as List).isNotEmpty) {
              host = settings['vnext'][0]['address'] ?? '';
              port = settings['vnext'][0]['port'] ?? 0;
              break;
            }
            if (settings['servers'] != null &&
                (settings['servers'] as List).isNotEmpty) {
              host = settings['servers'][0]['address'] ?? '';
              port = settings['servers'][0]['port'] ?? 0;
              break;
            }
          }
        }

        final stream = fullConfig['streamSettings'];
        if (stream != null) {
          network = stream['network'];
          security = stream['security'];
        }
      } catch (_) {}

      return V2RayConfig(
        raw: raw,
        protocol: protocol,
        name: parser.remark.isNotEmpty ? parser.remark : 'Server',
        host: host,
        port: port,
        network: network,
        security: security,
      );
    } catch (_) {
      return null;
    }
  }

  static String _detectProtocol(String raw) {
    if (raw.startsWith('vmess://')) return 'VMess';
    if (raw.startsWith('vless://')) return 'VLESS';
    if (raw.startsWith('trojan://')) return 'Trojan';
    if (raw.startsWith('ss://')) return 'Shadowsocks';
    return 'Unknown';
  }

  int? get bestPing => realPing ?? tcpPing;

  String get pingText {
    final p = bestPing;
    if (p == null) return '✕';
    return '$p';
  }

  String get shortName {
    if (name.length <= 30) return name;
    return '${name.substring(0, 30)}...';
  }

  String get protocolShort {
    if (protocol == 'Shadowsocks') return 'SS';
    return protocol;
  }

  Map<String, dynamic> toJson() => {
        'raw': raw,
        'protocol': protocol,
        'name': name,
        'isFavorite': isFavorite,
        'usedCount': usedCount,
        'lastUsed': lastUsed?.toIso8601String(),
      };

  static V2RayConfig? fromJson(Map<String, dynamic> json) {
    final cfg = fromRaw(json['raw'] ?? '');
    if (cfg == null) return null;
    cfg.isFavorite = json['isFavorite'] ?? false;
    cfg.usedCount = json['usedCount'] ?? 0;
    if (json['lastUsed'] != null) {
      cfg.lastUsed = DateTime.tryParse(json['lastUsed']);
    }
    return cfg;
  }

  V2RayConfig copyWith({
    bool? isFavorite,
    int? usedCount,
    DateTime? lastUsed,
  }) {
    return V2RayConfig(
      raw: raw,
      protocol: protocol,
      name: name,
      host: host,
      port: port,
      network: network,
      security: security,
      tcpPing: tcpPing,
      realPing: realPing,
      isFavorite: isFavorite ?? this.isFavorite,
      usedCount: usedCount ?? this.usedCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
