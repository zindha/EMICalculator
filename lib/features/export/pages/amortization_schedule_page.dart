import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/modern_glass_card.dart';
import '../../calculator/domain/models/amortization_month.dart';
import '../../../../core/theme/app_colors.dart';
import '../services/export_service.dart';

/// Screen that displays the full amortization schedule in a beautifully
/// striped list, with a floating action button for PDF/CSV export.
class AmortizationSchedulePage extends ConsumerWidget {
  /// Creates the [AmortizationSchedulePage].
  const AmortizationSchedulePage({
    super.key,
    required this.amortizationMonths,
    required this.loanAmount,
    required this.totalInterest,
    required this.totalPayment,
  });

  /// List of [AmortizationMonth] entries for the schedule.
  final List<dynamic> amortizationMonths;

  /// The original loan amount.
  final double loanAmount;

  /// The total interest payable.
  final double totalInterest;

  /// The total payment (principal + interest).
  final double totalPayment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final schedule = amortizationMonths.cast<AmortizationMonth>();
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    const exportService = ExportService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Amortization Schedule',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Export',
            onPressed: () => _showExportOptions(context, ref, schedule, exportService),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary Header ─────────────────────
          ModernGlassCard(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            tintColor: theme.colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  label: 'Loan Amount',
                  value: formatter.format(loanAmount),
                  color: theme.colorScheme.onSurface,
                ),
                _buildSummaryItem(
                  context,
                  label: 'Total Interest',
                  value: formatter.format(totalInterest),
                  color: AppColors.danger,
                ),
                _buildSummaryItem(
                  context,
                  label: 'Total Payment',
                  value: formatter.format(totalPayment),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),

          // ── Table Header ───────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _tableHeaderCell(context, '#', flex: 1),
                _tableHeaderCell(context, 'Opening', flex: 2),
                _tableHeaderCell(context, 'Principal', flex: 2),
                _tableHeaderCell(context, 'Interest', flex: 2),
                _tableHeaderCell(context, 'Closing', flex: 2),
              ],
            ),
          ),

          // ── Schedule List ──────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final entry = schedule[index];
                final isEven = index.isEven;

                return Container(
                  color: isEven
                      ? theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3)
                      : Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _tableCell(
                          context,
                          '${entry.monthNumber}',
                          flex: 1,
                          isBold: false,
                        ),
                        _tableCell(
                          context,
                          formatter.format(entry.openingBalance),
                          flex: 2,
                          isBold: false,
                        ),
                        _tableCell(
                          context,
                          formatter.format(entry.principalPaid),
                          flex: 2,
                          isBold: false,
                          color: AppColors.positive,
                        ),
                        _tableCell(
                          context,
                          formatter.format(entry.interestPaid),
                          flex: 2,
                          isBold: false,
                          color: AppColors.danger,
                        ),
                        _tableCell(
                          context,
                          formatter.format(entry.closingBalance),
                          flex: 2,
                          isBold: false,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a summary statistic item.
  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Builds a table header cell.
  Widget _tableHeaderCell(BuildContext context, String text,
      {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Builds a table data cell.
  Widget _tableCell(
    BuildContext context,
    String text, {
    int flex = 1,
    bool isBold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Shows a bottom sheet with export options.
  void _showExportOptions(
    BuildContext context,
    WidgetRef ref,
    List<AmortizationMonth> schedule,
    ExportService exportService,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export Schedule',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: const Text('Export as PDF'),
                  subtitle: const Text('Professional document with summary'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _exportPdf(context, ref, schedule, exportService);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded),
                  title: const Text('Export as CSV'),
                  subtitle: const Text('Open in spreadsheet apps'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _exportCsv(context, schedule, exportService);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Generates and shares a PDF.
  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    List<AmortizationMonth> schedule,
    ExportService exportService,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      // Calculate EMI from schedule data
      final firstEntry = schedule.isNotEmpty ? schedule.first : null;
      final emiAmount = firstEntry?.emiAmount ?? 0;

      // Estimate the interest rate and tenure from schedule length
      final tenureMonths = schedule.length;
      final interestRate = loanAmount > 0
          ? ((totalInterest / loanAmount) / tenureMonths) * 12 * 100
          : 0.0;

      final filePath = await exportService.generatePdf(
        schedule: schedule,
        loanAmount: loanAmount,
        totalInterest: totalInterest,
        totalPayment: totalPayment,
        emiAmount: emiAmount,
        interestRate: interestRate,
        tenureMonths: tenureMonths,
      );

      await exportService.sharePdf(filePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  /// Generates and shares a CSV.
  Future<void> _exportCsv(
    BuildContext context,
    List<AmortizationMonth> schedule,
    ExportService exportService,
  ) async {
    try {
      final csv = exportService.generateCsv(schedule: schedule);
      await exportService.shareCsv(csv);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
