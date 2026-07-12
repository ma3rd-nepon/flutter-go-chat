import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_go_chat/core/layers/particles/particles.dart';

abstract class ParticleEffect {
  final Random random = Random();
  String get id;

  void init(Size size);

  void update(Size size, double deltaTime);

  void paint(Canvas canvas, Size size);

  void dispose();
}

class SnowEffect extends ChangeNotifier implements ParticleEffect {
  final List<SnowParticle> _particles = [];
  final int _particleCount;
  final Random _random = Random();
  final _paint = Paint()
    ..color = const Color.fromARGB(125, 255, 255, 255)
    ..style = PaintingStyle.fill;

  SnowEffect({this._particleCount = 100});

  @override
  Random get random => _random;

  @override
  String get id => 'snow';

  @override
  void init(Size size) {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        SnowParticle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          speed: 50 + _random.nextDouble() * 100,
          size: 2 + _random.nextDouble() * 3,
          drift: -0.5 + _random.nextDouble(),
          phase: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(Size size, double deltaTime) {
    if (size.isEmpty || _particles.isEmpty) {
      return;
    }

    final safeDeltaTime = (deltaTime <= 0 ? 1 / 60 : deltaTime);

    for (final particle in _particles) {
      final windX = particle.drift * 35 + sin(particle.phase) * 0.8;
      final nextX = particle.x + windX * safeDeltaTime;
      final nextY = particle.y + particle.speed * safeDeltaTime;

      if (nextY > size.height + 5) {
        particle.x = _random.nextDouble() * size.width;
        particle.y = -5;
        particle.speed = 50 + _random.nextDouble() * 100;
        particle.size = 2 + _random.nextDouble() * 3;
        particle.drift = -0.5 + _random.nextDouble();
        particle.phase = _random.nextDouble() * 2 * pi;
      } else {
        particle.x = nextX < -5
            ? size.width + 5
            : nextX > size.width + 5
            ? -5
            : nextX;
        particle.y = nextY;
        particle.phase += safeDeltaTime * 0.35;
      }
    }
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, _paint);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class RainEffect extends ChangeNotifier implements ParticleEffect {
  // сделать пресет для грозы, наследовать отсюда
  final List<RainParticle> _particles = [];
  final int _particleCount;
  final Random _random = Random();
  final _paint = Paint()
    ..color = const Color.fromARGB(125, 173, 216, 230)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  RainEffect({this._particleCount = 100});

  @override
  Random get random => _random;

  @override
  String get id => 'rain';

  @override
  void init(Size size) {
    _particles.clear();
    final double angle = pi / 4 + (_random.nextDouble() - 0.5) * (pi / 8);
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        RainParticle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          speed: 200 + _random.nextDouble() * 300,
          length: 10 + _random.nextDouble() * 10,
          angle: angle,
        ),
      );
    }
  }

  @override
  void update(Size size, double deltaTime) {
    if (size.isEmpty || _particles.isEmpty) {
      return;
    }

    final safeDeltaTime = (deltaTime <= 0 ? 1 / 60 : deltaTime);

    for (final particle in _particles) {
      final nextX =
          particle.x + cos(particle.angle) * particle.speed * safeDeltaTime;
      final nextY =
          particle.y + sin(particle.angle) * particle.speed * safeDeltaTime;

      if (nextY > size.height + 5 || nextX > size.width + 5 || nextX < -5) {
        particle.x = _random.nextDouble() * size.width;
        particle.y = _random.nextDouble() * size.height;
        particle.speed = 200 + _random.nextDouble() * 300;
        particle.length = 10 + _random.nextDouble() * 10;
      } else {
        particle.x = nextX;
        particle.y = nextY;
      }
    }
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      final endX = particle.x + cos(particle.angle) * particle.length;
      final endY = particle.y + sin(particle.angle) * particle.length;
      canvas.drawLine(
        Offset(particle.x, particle.y),
        Offset(endX, endY),
        _paint,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class DustEffect extends ChangeNotifier implements ParticleEffect {
  final List<DustParticle> _particles = [];
  final int _particleCount;
  final Random _random = Random();
  final _paint = Paint()
    ..color = const Color.fromARGB(125, 255, 255, 255)
    ..style = PaintingStyle.fill;

  DustEffect({this._particleCount = 100});

  @override
  Random get random => _random;

  @override
  String get id => 'dust';

  @override
  void init(Size size) {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        DustParticle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          velocityX: (_random.nextDouble() - 0.5) * 20,
          velocityY: (_random.nextDouble() - 0.5) * 20,
          size: 2 + _random.nextDouble() * 2,
        ),
      );
    }
  }

  @override
  void update(Size size, double deltaTime) {
    if (size.isEmpty || _particles.isEmpty) {
      return;
    }

    final safeDeltaTime = (deltaTime <= 0 ? 1 / 60 : deltaTime);

    for (final particle in _particles) {
      final nextX = particle.x + (particle.velocityX * safeDeltaTime);
      final nextY = particle.y + (particle.velocityY * safeDeltaTime);

      if (nextX < -5 || nextX > size.width + 5) {
        particle.velocityX *= -1;
      }

      if (nextY < -5 || nextY > size.height + 5) {
        particle.velocityY *= -1;
      } else {
        particle.x = nextX;
        particle.y = nextY;
      }
    }
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, _paint);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class NetworkEffect extends ChangeNotifier implements ParticleEffect {
  // намутить наследование из DustEffect, чтобы не дублировать код, но пока оставим так
  final List<NetworkParticle> _particles = [];
  final int _particleCount;
  final Random _random = Random();
  final int _maxConnections = 3;
  final double _connectionRange = 100.0;
  final cellSize = 50;
  final Map<(int, int), List<NetworkParticle>> cellGrid = {};
  final _paint = Paint()
    ..color = const Color.fromARGB(125, 173, 216, 230)
    ..style = PaintingStyle.fill;

  NetworkEffect({this._particleCount = 100});

  @override
  String get id => 'network';

  @override
  Random get random => _random;

  @override
  void init(Size size) {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      final p = NetworkParticle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        cellSize: cellSize,
        velocityX: (_random.nextDouble() - 0.5) * 20,
        velocityY: (_random.nextDouble() - 0.5) * 20,
        size: 2 + _random.nextDouble() * 2,
        maxConnections: _maxConnections,
        connectionRange: _connectionRange,
      );
      _particles.add(p);
      cellGrid.putIfAbsent((p.cellX, p.cellY), () => []).add(p);
    }
  }

  @override
  void update(Size size, double deltaTime) {
    if (size.isEmpty || _particles.isEmpty) {
      return;
    }
    cellGrid.clear();

    final safeDeltaTime = (deltaTime <= 0 ? 1 / 60 : deltaTime);

    for (final particle in _particles) {
      final nextX = particle.x + (particle.velocityX * safeDeltaTime);
      final nextY = particle.y + (particle.velocityY * safeDeltaTime);

      if (nextX < -5 || nextX > size.width + 5) {
        particle.velocityX *= -1;
      }

      if (nextY < -5 || nextY > size.height + 5) {
        particle.velocityY *= -1;
      } else {
        particle.x = nextX;
        particle.y = nextY;
      }

      cellGrid
          .putIfAbsent((particle.cellX, particle.cellY), () => [])
          .add(particle);
      // O (n^2) сложность, нужна оптимизация
      // if (particle.maxConnections > 0) {
      //   List<NetworkParticle> connections = [];
      //   for (final other in _particles) {
      //     if (other == particle) continue;
      //     final distance = sqrt(
      //       pow(particle.x - other.x, 2) + pow(particle.y - other.y, 2),
      //     );
      //     if (distance < particle.connectionRange &&
      //         connections.length < particle.maxConnections &&
      //         other.connections.length < other.maxConnections) {
      //       connections.add(other);
      //     }
      //     if (connections.length >= particle.maxConnections) break;
      //   }
      //   particle.connections = connections;
      // }
    }

    for (final particle in _particles) {
      if (particle.maxConnections > 0) {
        List<NetworkParticle> connections = [];
        for (int dx = -1; dx <= 1; dx++) {
          if (connections.length > particle.maxConnections) break;
          for (int dy = -1; dy <= 1; dy++) {
            if (connections.length > particle.maxConnections) break;

            final neighbours =
                cellGrid[(particle.cellX + dx, particle.cellY + dy)];
            if (neighbours == null) continue;

            for (final other in neighbours) {
              if (connections.length > particle.maxConnections) break;

              final dx = particle.x - other.x;
              final dy = particle.y - other.y;

              final distanceSq = dx * dx + dy * dy;

              if (distanceSq <
                  particle.connectionRange * particle.connectionRange) {
                connections.add(other);
              }
            }
          }
        }
        particle.connections = connections;
      }
    }
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || _particles.isEmpty) {
      return;
    }

    for (final particle in _particles) {
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, _paint);
      if (particle.maxConnections > 0) {
        for (final connection in particle.connections) {
          canvas.drawLine(
            Offset(particle.x, particle.y),
            Offset(connection.x, connection.y),
            _paint,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}


class StarRainEffect extends ChangeNotifier implements ParticleEffect {
  final List<StarParticle> _particles = [];
  final int _particleCount;
  final Random _random = Random();
  final _paint = Paint()
    ..color = const Color.fromARGB(50, 255, 255, 255)
    ..style = PaintingStyle.fill;

  StarRainEffect({this._particleCount = 20});

  @override
  Random get random => _random;

  @override
  String get id => 'starrain';

  @override
  void init(Size size) {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        StarParticle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          size: 2 + _random.nextDouble() * 10,
          phase: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(Size size, double deltaTime) {
    if (size.isEmpty || _particles.isEmpty) {
      return;
    }

    final safeDeltaTime = (deltaTime <= 0 ? 1 / 60 : deltaTime);

    for (final particle in _particles) {
      final windX = 0.7 * 35 + sin(particle.phase) * 0.8;
      final nextX = particle.x + windX * safeDeltaTime;
      final nextY = particle.y + 20 * safeDeltaTime;
      final nextSize = particle.size + _random.nextDouble() * safeDeltaTime * 20 * pow(-1, random.nextInt(2));


      if (nextY > size.height + 5 || nextSize < 0.1) {
        particle.x = _random.nextDouble() * size.width;
        particle.y = -5;
        particle.size = 2 + _random.nextDouble() * 3;
        particle.phase = _random.nextDouble() * 2 * pi;
      } else {
        particle.x = nextX < -5
            ? size.width + 5
            : nextX > size.width + 5
            ? -5
            : nextX;
        particle.y = nextY;
        particle.size = nextSize;
        particle.phase += safeDeltaTime * 0.35;
      }
    }
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, _paint);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}