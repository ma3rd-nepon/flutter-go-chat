import 'dart:convert';

import 'package:flutter_go_chat/core/layers/wallpaper/wallaper_type.dart';

class SettingsData {
  final String cl;
  final bool ug;
  final double gb;
  final double go;
  final WallpaperType wt;
  final Map<String, dynamic> wc;
  final String? pei;
  final bool se;
  final String? si;
  final String ct;
  final String ca;

  const SettingsData({
    required this.cl,
    required this.ug,
    required this.gb,
    required this.go,
    required this.wt,
    required this.wc,
    required this.pei,
    required this.se,
    required this.si,
    required this.ct,
    required this.ca
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
  return SettingsData(
    cl: json['current_locale'] ?? 'en',
    ug: json['use_glass'] ?? false,
    gb: (json['glass_blur'] ?? 0).toDouble(),
    go: (json['glass_opacity'] ?? 1).toDouble(),
    wt: WallpaperType.values.firstWhere(
      (e) => e.name == json['wallpaper_type'],
      orElse: () => WallpaperType.color,
    ),
    wc: Map<String, dynamic>.from(
      json['wallpaper_content'] ?? {},
    ),
    pei: json['particle_effect_id'],
    se: json['shaders_enabled'] ?? false,
    si: json['shader_id'],
    ct: json['current_theme'],
    ca: json['current_accent']
  );
}

  Map<String, dynamic> toJson() => {
    "current_locale": cl,
    "use_glass" : ug,
    "glass_blur": gb,
    "glass_opacity": go,
    "wallpaper_type": "${wt.name}",
    "wallpaper_content": {
      "color": wc["color"],
      "gradient": wc["gradient"],
      "asset": wc["asset"],
      "network_url": wc["network_url"]
    },
    "particle_effect_id": pei,
    "shaders_enabled": se,
    "shader_id": si,
    "current_theme": ct,
    "current_accent": ca,
  };

  String toRawJson() => jsonEncode(toJson());
}