import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/prepayment_result.dart';

/// A pie chart that visualizes the total cost breakdown of a prepayment plan.
///
/// Displays three slices:
/// - Principal (the original loan amount used in the simulation)
/// - Interest (total interest paid after prepayments)
/// - Extra Prepayments (all additional payments made)
class PrepaymentPieChart extends StatelessWidget {
  /// Creates a [PrepaymentPieChart].
  const PrepaymentPieChart({
    super.key,
    required this.result,
  });

  /// The prepayment simulation result.
  final PrepaymentResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final principal = result.updatedSchedule.isNotEmpty
        ? result.updatedSchedule.first.openingBalance
        : 0.0;
    final interest = result.updatedTotalInterest;
    final extra = result.totalExtraPayments;

    final sections = <PieChartSectionData>[];
    final legend = <_LegendItem>[];

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFE74C3C),
      const Color(0xFF2ECC71),
    ];

    final entries = [
      _PieEntry(label: 'Principal', value: principal, color: colors[0]),
      _PieEntry(label: 'Interest', value: interest, color: colors[1]),
      _PieEntry(label: 'Extra Payments', value: extra, color: colors[2]),
    ];

    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    for (final entry in entries) {
      sections.add(
        PieChartSectionData(
          value: entry.value,
          color: entry.color,
          title: total > 0 ? '${_percentage(entry.value, total)}%' : '',
          radius: 70,
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
      legend.add(_LegendItem(entry.label, entry.color, entry.value));
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 32,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legend.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '₹${_formatCompact(item.value)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  int _percentage(double part, double total) {
    if (total == 0) return 0;
    return ((part / total) * 100).round();
  }

  String _formatCompact(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _PieEntry {
  const _PieEntry(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _LegendItem {
  const _LegendItem(this.label, this.color, this.value);

  final String label;
  final Color color;
  final double value;
}
