import 'package:flutter/material.dart';

/// Jauge d'occupation circulaire avec pourcentage
class OccupancyGauge extends StatelessWidget {
  final double occupancyRate; // 0.0 to 100.0
  final String label;
  final double size;

  const OccupancyGauge({
    super.key,
    required this.occupancyRate,
    this.label = 'Occupation',
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRate = occupancyRate.clamp(0.0, 100.0);
    final percentage = (clampedRate / 100).clamp(0.0, 1.0);

    // Couleur dépendant du taux
    Color getColor() {
      if (clampedRate < 30) {
        return Colors.red;
      } else if (clampedRate < 60) {
        return Colors.amber;
      } else {
        return Colors.green;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercle de fond (gris)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
              // Arc de remplissage
              CustomPaint(
                size: Size(size, size),
                painter: _OccupancyArcPainter(
                  percentage: percentage,
                  color: getColor(),
                ),
              ),
              // Texte au centre
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${clampedRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Indication de couleur
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getColor(),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter pour dessiner l'arc de remplissage
class _OccupancyArcPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _OccupancyArcPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Arc de remplissage
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Dessiner l'arc de -π/2 à -π/2 + (percentage * 2π)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Commencer au haut
      (percentage * 2 * 3.14159),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OccupancyArcPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
