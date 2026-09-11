class V2RayConfig {
  final String raw;
  final String protocol;
  final String name;
  final String host;
  final int port;
  int? tcpPing;
  int? realPing;
  bool isFavorite;

  V2RayConfig({
    required this.raw,
    required this.protocol,
    required this.name,
    required this.host,
    required this.port,
    this.tcpPing,
    this.realPing,
    this.isFavorite = false,
  });

  static V2RayConfig? fromRaw(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return null;

    String protocol;
    if (raw.startsWith('vmess://')) {
      protocol = 'VMess';
    } else if (raw.startsWith('vless://')) {
      protocol = 'VLESS';
    } else if (raw.startsWith('trojan://')) {
      protocol = 'Trojan';
    } else if (raw.startsWith('ss://')) {
      protocol = 'Shadowsocks';
    } else {
      return null;
    }

    String host = '';
    int port = 0;
    String name = 'Server';

    try {
      final uri = Uri.parse(raw);
      host = uri.host;
      port = uri.hasPort ? uri.port : 443;
      if (uri.fragment.isNotEmpty) {
        name = Uri.decodeComponent(uri.fragment);
      }
    } catch (_) {}

    return V2RayConfig(
      raw: raw,
      protocol: protocol,
      name: name,
      host: host,
      port: port,
    );
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
        'isFavorite': isFavorite,
      };

  static V2RayConfig? fromJson(Map<String, dynamic> json) {
    final cfg = fromRaw(json['raw'] ?? '');
    if (cfg == null) return null;
    cfg.isFavorite = json['isFavorite'] ?? false;
    return cfg;
  }
}
