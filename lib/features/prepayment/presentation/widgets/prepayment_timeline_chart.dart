import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/prepayment_result.dart';

/// Line chart that compares the original loan balance with the updated
/// balance after prepayments.
class PrepaymentTimelineChart extends StatelessWidget {
  /// Creates a [PrepaymentTimelineChart].
  const PrepaymentTimelineChart({
    super.key,
    required this.result,
  });

  /// The prepayment simulation result.
  final PrepaymentResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final originalSpots = <FlSpot>[
      FlSpot(0.0, result.updatedSchedule.isNotEmpty
          ? result.updatedSchedule.first.openingBalance
          : 0.0),
    ];

    for (final entry in result.updatedSchedule) {
      originalSpots.add(
        FlSpot(entry.monthNumber.toDouble(), entry.closingBalance),
      );
    }

    final updatedSpots = <FlSpot>[];
    for (final entry in result.updatedSchedule) {
      updatedSpots.add(
        FlSpot(entry.monthNumber.toDouble(), entry.closingBalance),
      );
    }

    final maxBalance = result.updatedSchedule.isNotEmpty
        ? result.updatedSchedule.first.openingBalance * 1.1
        : 1.0;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (result.updatedSchedule.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                return Text(
                  'M${value.toInt()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCompact(value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 9),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: result.updatedSchedule.length.toDouble(),
        minY: 0.0,
        maxY: maxBalance,
        lineBarsData: [
          LineChartBarData(
            spots: updatedSpots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(0)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(0)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
