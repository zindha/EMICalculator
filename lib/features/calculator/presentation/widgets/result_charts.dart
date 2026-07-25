import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/calculator_provider.dart';

/// Widget that displays two charts: a pie chart showing the principal vs.
/// interest breakdown, and a line chart showing the loan balance over time.
class ResultCharts extends ConsumerWidget {
  /// Creates a [ResultCharts].
  const ResultCharts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(emiResultNotifierProvider);

    if (result == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pie Chart: Principal vs Interest ────
        _buildSectionTitle(context, 'Principal vs Interest'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _PrincipalVsInterestPieChart(
            principal: result.effectiveLoanAmount,
            totalInterest: result.totalInterest,
          ),
        ),
        const SizedBox(height: 24),

        // ── Line Chart: Balance Over Time ───────
        _buildSectionTitle(context, 'Loan Balance Over Time'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _BalanceLineChart(
            amortizationSchedule: result.amortizationSchedule,
            principal: result.effectiveLoanAmount,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A pie chart showing the split between principal and total interest.
class _PrincipalVsInterestPieChart extends StatelessWidget {
  const _PrincipalVsInterestPieChart({
    required this.principal,
    required this.totalInterest,
  });

  final double principal;
  final double totalInterest;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    final total = principal + totalInterest;
    final principalPercent =
        total > 0 ? (principal / total * 100).toStringAsFixed(1) : '0';
    final interestPercent =
        total > 0 ? (totalInterest / total * 100).toStringAsFixed(1) : '0';

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(
                color: const Color(0xFF6C63FF),
                value: max(principal, 1),
                title: '$principalPercent%',
                titleStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                radius: 35,
              ),
              PieChartSectionData(
                color: const Color(0xFFE74C3C),
                value: max(totalInterest, 1),
                title: '$interestPercent%',
                titleStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                radius: 35,
              ),
            ],
          ),
        ),
        // Center widget overlay
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              formatter.format(total),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A line chart showing the loan balance decreasing over time.
class _BalanceLineChart extends StatelessWidget {
  const _BalanceLineChart({
    required this.amortizationSchedule,
    required this.principal,
  });

  final List<dynamic> amortizationSchedule;
  final double principal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedule = amortizationSchedule;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    if (schedule.isEmpty) {
      return Center(
        child: Text(
          'No amortization data',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Sample data points to prevent overcrowding.
    const maxPoints = 12;
    final step = max(1, (schedule.length / maxPoints).ceil());
    final sampledIndices = <int>[];
    for (int i = 0; i < schedule.length; i += step) {
      sampledIndices.add(i);
    }
    // Always include the last month.
    if (sampledIndices.last != schedule.length - 1) {
      sampledIndices.add(schedule.length - 1);
    }

    final maxBalance = principal;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxBalance / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
              strokeWidth: 1,
            );
          },
        ),
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
              reservedSize: 28,
              interval: (schedule.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final month = value.toInt();
                if (month < 0 || month >= schedule.length) {
                  return const SizedBox.shrink();
                }
                final entry = schedule[month] as dynamic;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'M${entry.monthNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  formatter.format(value),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (schedule.length - 1).toDouble(),
        minY: 0,
        maxY: maxBalance * 1.1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final entry = schedule[spot.spotIndex] as dynamic;
                return LineTooltipItem(
                  'M${entry.monthNumber}: ${formatter.format(entry.closingBalance)}',
                  GoogleFonts.interTextTheme().bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: sampledIndices.map((i) {
              final entry = schedule[i] as dynamic;
              return FlSpot(i.toDouble(), entry.closingBalance);
            }).toList(),
            isCurved: true,
            preventCurveOverShooting: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.12),
                  theme.colorScheme.primary.withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
