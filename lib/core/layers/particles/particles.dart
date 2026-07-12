class SnowParticle {
  double x;
  double y;

  double speed;
  double size;

  double drift;
  double phase;

  SnowParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.drift,
    required this.phase,
  });
}

class RainParticle {
  double x;
  double y;

  double speed;
  double length;

  double angle;

  RainParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.angle,
  });
}

class DustParticle {
  double x;
  double y;

  double velocityX;
  double velocityY;
  double size;

  DustParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.size,
  });
}

class NetworkParticle {
  double x;
  double y;

  int cellSize;

  int get cellX => (x / cellSize).floor();
  int get cellY => (y / cellSize).floor();

  double size;

  double velocityX;
  double velocityY;

  int maxConnections;
  double connectionRange;

  List<NetworkParticle> connections = [];

  NetworkParticle({
    required this.x,
    required this.y,
    required this.cellSize,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.maxConnections,
    required this.connectionRange,
  });
}

class StarParticle {
  double x;
  double y;

  double size;

  double phase;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.phase
  });
}