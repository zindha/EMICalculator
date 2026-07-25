import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/comparison_result.dart';
import '../../domain/models/loan_offer.dart';

/// Widget that displays comparison charts for a list of loan offers.
///
/// Includes a grouped bar chart for EMI/total interest/total payment, a
/// stacked interest-vs-principal bar chart, a pie chart showing the
/// principal/interest breakdown for a selected offer, and a simple savings
/// bar chart relative to the most expensive offer.
class ComparisonCharts extends StatefulWidget {
  /// Creates a [ComparisonCharts].
  const ComparisonCharts({
    super.key,
    required this.result,
    required this.offers,
  });

  /// The analyzed comparison result.
  final ComparisonResult result;

  /// The loan offers in display order.
  final List<LoanOffer> offers;

  @override
  State<ComparisonCharts> createState() => _ComparisonChartsState();
}

class _ComparisonChartsState extends State<ComparisonCharts> {
  int _selectedPieIndex = 0;

  @override
  Widget build(BuildContext context) {
    final safeIndex = _selectedPieIndex.clamp(0, widget.offers.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Cost Comparison'),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: _GroupedBarChart(result: widget.result, offers: widget.offers),
        ),
        const SizedBox(height: 32),

        _buildSectionTitle(context, 'Principal vs Interest'),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: _PrincipalInterestChart(result: widget.result, offers: widget.offers),
        ),
        const SizedBox(height: 32),

        _buildSectionTitle(context, 'Payment Breakdown'),
        const SizedBox(height: 12),
        _buildPieChartHeader(context, safeIndex),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: _PaymentBreakdownPieChart(
            result: widget.result,
            offers: widget.offers,
            selectedIndex: safeIndex,
          ),
        ),
        const SizedBox(height: 32),

        _buildSectionTitle(context, 'Savings Chart'),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: _SavingsChart(result: widget.result, offers: widget.offers),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPieChartHeader(BuildContext context, int selectedIndex) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.offers.asMap().entries.map((entry) {
          final index = entry.key;
          final offer = entry.value;
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                offer.name,
                style: GoogleFonts.inter(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPieIndex = index),
              selectedColor: theme.colorScheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GroupedBarChart extends StatelessWidget {
  const _GroupedBarChart({required this.result, required this.offers});

  final ComparisonResult result;
  final List<LoanOffer> offers;

  @override
  Widget build(BuildContext context) {
    final metrics = offers
        .map((o) => result.offers[o.id])
        .whereType<LoanOfferMetrics>()
        .toList();

    final maxValue = metrics
        .map((m) => [m.emi, m.totalInterest, m.totalPayment]
            .reduce((a, b) => a > b ? a : b))
        .fold(0.0, (prev, curr) => curr > prev ? curr : prev);

    return BarChart(
      BarChartData(
        maxY: maxValue * 1.2,
        barGroups: metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: m.emi,
                color: const Color(0xFF6C63FF),
                width: 12,
              ),
              BarChartRodData(
                toY: m.totalInterest,
                color: const Color(0xFFE74C3C),
                width: 12,
              ),
              BarChartRodData(
                toY: m.totalPayment,
                color: const Color(0xFF00C9A7),
                width: 12,
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= offers.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    offers[index].name,
                    style: GoogleFonts.inter(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _PrincipalInterestChart extends StatelessWidget {
  const _PrincipalInterestChart({required this.result, required this.offers});

  final ComparisonResult result;
  final List<LoanOffer> offers;

  @override
  Widget build(BuildContext context) {
    final metrics = offers
        .map((o) => result.offers[o.id])
        .whereType<LoanOfferMetrics>()
        .toList();

    final maxValue = metrics
        .map((m) => m.effectiveLoanAmount + m.totalInterest)
        .fold(0.0, (prev, curr) => curr > prev ? curr : prev);

    return BarChart(
      BarChartData(
        maxY: maxValue * 1.2,
        barGroups: metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: m.effectiveLoanAmount,
                color: const Color(0xFF6C63FF),
                width: 24,
              ),
              BarChartRodData(
                toY: m.totalInterest,
                color: const Color(0xFFE74C3C),
                width: 24,
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= offers.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    offers[index].name,
                    style: GoogleFonts.inter(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _PaymentBreakdownPieChart extends StatelessWidget {
  const _PaymentBreakdownPieChart({
    required this.result,
    required this.offers,
    required this.selectedIndex,
  });

  final ComparisonResult result;
  final List<LoanOffer> offers;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offer = offers[selectedIndex];
    final metrics = result.offers[offer.id];

    if (metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final sections = <PieChartSectionData>[];
    final legendItems = <_PieLegendItem>[];

    final principal = metrics.effectiveLoanAmount;
    final interest = metrics.totalInterest;
    final total = principal + interest;

    if (total <= 0) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    sections.add(
      PieChartSectionData(
        value: principal,
        title: '${_percentage(principal, total)}%',
        color: const Color(0xFF6C63FF),
        radius: 80,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
    legendItems.add(_PieLegendItem('Principal', const Color(0xFF6C63FF), principal));

    sections.add(
      PieChartSectionData(
        value: interest,
        title: '${_percentage(interest, total)}%',
        color: const Color(0xFFE74C3C),
        radius: 80,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
    legendItems.add(_PieLegendItem('Interest', const Color(0xFFE74C3C), interest));

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legendItems.map((item) {
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

class _PieLegendItem {
  const _PieLegendItem(this.label, this.color, this.value);

  final String label;
  final Color color;
  final double value;
}

class _SavingsChart extends StatelessWidget {
  const _SavingsChart({required this.result, required this.offers});

  final ComparisonResult result;
  final List<LoanOffer> offers;

  @override
  Widget build(BuildContext context) {
    final metrics = offers
        .map((o) => result.offers[o.id])
        .whereType<LoanOfferMetrics>()
        .toList();

    final maxPayment = metrics
        .map((m) => m.totalPayment)
        .fold(0.0, (prev, curr) => curr > prev ? curr : prev);

    return BarChart(
      BarChartData(
        maxY: maxPayment * 1.1,
        barGroups: metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          final savings = maxPayment - m.totalPayment;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: savings,
                color: savings == 0
                    ? Colors.grey
                    : const Color(0xFF2ECC71),
                width: 28,
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= offers.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    offers[index].name,
                    style: GoogleFonts.inter(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
