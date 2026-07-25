import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/what_if_result.dart';

/// Pie chart that compares the principal/interest breakdown between the
/// baseline and current what-if scenarios.
class WhatIfPieChart extends StatefulWidget {
  /// Creates a [WhatIfPieChart].
  const WhatIfPieChart({
    super.key,
    required this.result,
  });

  /// The what-if comparison result.
  final WhatIfComparisonResult result;

  @override
  State<WhatIfPieChart> createState() => _WhatIfPieChartState();
}

class _WhatIfPieChartState extends State<WhatIfPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPie(
                context,
                label: 'Baseline',
                result: widget.result.baseline,
                color: const Color(0xFF6C63FF),
                interestColor: const Color(0xFFE74C3C),
                indexOffset: 0,
              ),
            ),
            Expanded(
              child: _buildPie(
                context,
                label: 'New',
                result: widget.result.current,
                color: const Color(0xFF00C9A7),
                interestColor: const Color(0xFFF39C12),
                indexOffset: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              'Baseline Principal',
              const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 12),
            _buildLegendItem(
              'Baseline Interest',
              const Color(0xFFE74C3C),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              'New Principal',
              const Color(0xFF00C9A7),
            ),
            const SizedBox(width: 12),
            _buildLegendItem(
              'New Interest',
              const Color(0xFFF39C12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPie(
    BuildContext context, {
    required String label,
    required WhatIfScenarioResult result,
    required Color color,
    required Color interestColor,
    required int indexOffset,
  }) {
    final theme = Theme.of(context);
    final total = result.effectiveLoanAmount + result.totalInterest;

    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: result.effectiveLoanAmount,
        color: color,
        title: total > 0
            ? '${((result.effectiveLoanAmount / total) * 100).round()}%'
            : '',
        radius: _touchedIndex == indexOffset ? 55 : 50,
        titleStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: result.totalInterest,
        color: interestColor,
        title: total > 0
            ? '${((result.totalInterest / total) * 100).round()}%'
            : '',
        radius: _touchedIndex == indexOffset + 1 ? 55 : 50,
        titleStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 25,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse?.touchedSection != null) {
                      _touchedIndex = pieTouchResponse!
                              .touchedSection!
                              .touchedSectionIndex +
                          indexOffset;
                    } else {
                      _touchedIndex = -1;
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11),
        ),
      ],
    );
  }
}
