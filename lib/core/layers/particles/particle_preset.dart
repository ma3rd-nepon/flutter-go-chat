import 'package:flutter_go_chat/core/layers/particles/particle_effect.dart';

enum ParticlePreset {
  snow('snow', 'Snow', SnowEffect.new),
  rain('rain', 'Rain', RainEffect.new),
  dust('dust', 'Dust', DustEffect.new),
  network('network', 'Network', NetworkEffect.new),
  starrain('starrain', 'Star Rain', StarRainEffect.new);

  const ParticlePreset(this.id, this.label, this.builder);

  final String id;
  final String label;
  final ParticleEffect Function() builder;
}