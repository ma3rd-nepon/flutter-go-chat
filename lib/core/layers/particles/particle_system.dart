import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter/src/scheduler/ticker.dart';

import 'package:flutter_go_chat/core/layers/particles/particle_effect.dart';
import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

class ParticleSystem extends StatefulWidget {
  const ParticleSystem({super.key});

  @override
  State<ParticleSystem> createState() => ParticleSystemState();
}

class ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ParticleEffect? _currentEffect;
  Size? _size;
  DateTime? _lastFrameTime;
  bool _effectInitialized = false;
  String? _activeEffectId;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => _handleFrame());
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final g = GlobalScreenManager.of(context);
    _syncEffect(g.particleEffectId);
  }

  void _syncEffect(String? effectId) {
    if (_activeEffectId == effectId && _effectInitialized && _size != null) {
      return;
    }

    _activeEffectId = effectId;
    _lastFrameTime = null;
    _currentEffect?.dispose();

    switch (effectId) {
      case 'snow':
        _currentEffect = SnowEffect();
        break;
      case 'rain':
        _currentEffect = RainEffect();
        break;
      case 'network':
        _currentEffect = NetworkEffect();
        break;
      case 'dust':
        _currentEffect = DustEffect();
        break;
      case 'starrain':
        _currentEffect = StarRainEffect();
        break;
      default:
        _currentEffect = null;
    }

    _effectInitialized = false;
    if (_size != null) {
      _currentEffect?.init(_size!);
      _effectInitialized = true;
    }
  }

  void _handleFrame() {
    if (!mounted || _currentEffect == null || _size == null) {
      return;
    }

    final now = DateTime.now();
    final lastFrameTime = _lastFrameTime;
    final deltaTime = lastFrameTime == null
        ? 1 / 60
        : (now.difference(lastFrameTime).inMicroseconds / 1e6).clamp(0.0, 0.05);

    _lastFrameTime = now;
    _currentEffect!.update(_size!, deltaTime);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _currentEffect?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        if (!_effectInitialized || _size != size) {
          _size = size;
          _currentEffect?.init(size);
          _effectInitialized = true;
          _lastFrameTime = null;
        }

        return RepaintBoundary(
          child: CustomPaint(painter: ParticlePainter(_currentEffect)),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter(this.currentEffect)
    : super(
        repaint: currentEffect is Listenable
            ? currentEffect as Listenable
            : null,
      );

  final ParticleEffect? currentEffect;

  @override
  void paint(Canvas canvas, Size size) {
    currentEffect?.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}
