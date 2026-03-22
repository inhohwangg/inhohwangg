import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ConversionProgress extends StatelessWidget {
  final double progress;

  const ConversionProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = (progress * 100).toInt();

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SpinKitWave(
              color: colorScheme.primary,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              '변환 중...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: progress.clamp(0.0, 1.0),
              lineHeight: 12,
              backgroundColor: colorScheme.surface,
              progressColor: colorScheme.primary,
              barRadius: const Radius.circular(6),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              progress > 0 ? '$percent%' : '처리 중...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
