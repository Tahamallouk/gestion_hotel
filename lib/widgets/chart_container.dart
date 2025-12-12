import 'package:flutter/material.dart';

/// Widget wrapper pour afficher un graphique avec titre et options
class ChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final String? description;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final double height;

  const ChartContainer({
    super.key,
    required this.title,
    required this.chart,
    this.description,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec titre et bouton refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Rafraîchir',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Contenu : graphique ou erreur ou loading
            if (isLoading)
              SizedBox(
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              SizedBox(
                height: height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Erreur',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(height: height, child: chart),
          ],
        ),
      ),
    );
  }
}
