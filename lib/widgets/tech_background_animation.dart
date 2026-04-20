import 'package:flutter/material.dart';
import 'dart:math' as math;

class TechBackgroundAnimation extends StatefulWidget {
  const TechBackgroundAnimation({super.key});

  @override
  State<TechBackgroundAnimation> createState() => _TechBackgroundAnimationState();
}

class _TechBackgroundAnimationState extends State<TechBackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<_CircuitPath> _paths = [];
  final List<_CircuitNode> _nodes = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _generateCircuitry();
  }

  void _generateCircuitry() {
    const double gridSize = 45.0;
    const int cols = 15;
    const int rows = 30;

    // Generate stable paths
    for (int i = 0; i < 20; i++) {
      double startX = (_random.nextInt(cols) * gridSize);
      double startY = (_random.nextInt(rows) * gridSize);
      
      List<Offset> points = [Offset(startX, startY)];
      double curX = startX;
      double curY = startY;

      for (int j = 0; j < 4; j++) {
        int dir = _random.nextInt(4);
        double dist = (1 + _random.nextInt(3)) * gridSize;
        
        if (dir == 0) curX += dist;
        else if (dir == 1) curX -= dist;
        else if (dir == 2) curY += dist;
        else curY -= dist;
        
        points.add(Offset(curX, curY));

        if (_random.nextDouble() > 0.6) {
          _nodes.add(_CircuitNode(
            Offset(curX, curY), 
            _random.nextBool(),
            _random.nextDouble(),
          ));
        }
      }
      _paths.add(_CircuitPath(points, 0.5 + _random.nextDouble() * 1.5));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          painter: _CircuitBoardPainter(
            paths: _paths,
            nodes: _nodes,
            progress: _pulseController.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _CircuitNode {
  final Offset position;
  final bool isSquare;
  final double delay;
  _CircuitNode(this.position, this.isSquare, this.delay);
}

class _CircuitPath {
  final List<Offset> points;
  final double speed;
  _CircuitPath(this.points, this.speed);
}

class _CircuitBoardPainter extends CustomPainter {
  final List<_CircuitPath> paths;
  final List<_CircuitNode> nodes;
  final double progress;

  _CircuitBoardPainter({
    required this.paths,
    required this.nodes,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Static circuit lines (using a darker tone for visibility on beige)
    final linePaint = Paint()
      ..color = const Color(0xFF64343C).withAlpha(40) // Plum tone from palette
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var path in paths) {
      final p = Path();
      p.moveTo(path.points[0].dx % size.width, path.points[0].dy % size.height);
      for (int i = 1; i < path.points.length; i++) {
        p.lineTo(path.points[i].dx % size.width, path.points[i].dy % size.height);
      }
      canvas.drawPath(p, linePaint);
      
      // 2. Moving energy pulse
      _drawEnergyPulse(canvas, path, size);
    }

    // 3. Glowing nodes
    for (var node in nodes) {
      final pos = Offset(node.position.dx % size.width, node.position.dy % size.height);
      final pulseAlpha = (0.4 + 0.6 * math.sin((progress + node.delay) * math.pi * 2)).clamp(0.0, 1.0);
      
      final glowPaint = Paint()
        ..color = const Color(0xFFB8860B).withAlpha((100 * pulseAlpha).toInt()) // DarkGold
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
      final nodePaint = Paint()
        ..color = const Color(0xFFB8860B).withAlpha((220 * pulseAlpha).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, 8, glowPaint);
      
      if (node.isSquare) {
        canvas.drawRect(Rect.fromCenter(center: pos, width: 5, height: 5), nodePaint);
      } else {
        canvas.drawCircle(pos, 2.5, nodePaint);
      }
    }
  }

  void _drawEnergyPulse(Canvas canvas, _CircuitPath circuitPath, Size size) {
    final double pathProgress = (progress * circuitPath.speed) % 1.0;
    
    // Pulse color - Amber for visibility on beige
    const Color pulseColor = Color(0xFFD4AF37); // Metallic Gold

    int numSegments = circuitPath.points.length - 1;
    double segmentT = pathProgress * numSegments;
    int index = segmentT.floor();
    double t = segmentT - index;

    Offset start = circuitPath.points[index];
    Offset end = circuitPath.points[index + 1];

    Offset currentPos = Offset(
      (start.dx + (end.dx - start.dx) * t) % size.width,
      (start.dy + (end.dy - start.dy) * t) % size.height,
    );

    canvas.drawCircle(
      currentPos, 
      4, 
      Paint()..color = pulseColor.withAlpha(120)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
    );
    
    canvas.drawCircle(
      currentPos, 
      1.8, 
      Paint()..color = pulseColor..style = PaintingStyle.fill
    );
  }

  @override
  bool shouldRepaint(covariant _CircuitBoardPainter oldDelegate) => true;
}
