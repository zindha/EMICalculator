import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../export/services/export_service.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../../shared/widgets/image_export_service.dart';
import '../../../../shared/widgets/number_formatter.dart';
import '../../domain/models/amortization_month.dart';
import '../../domain/models/emi_calculation.dart';
import '../providers/calculator_provider.dart';

import 'package:emi_calculator/core/services/notification_service.dart';

/// Saves the current calculation to history.
Future<void> saveCalculationToHistory(
  BuildContext context,
  WidgetRef ref,
  EmiCalculation input,
) async {
  final formatted = NumberFormatter.createCurrencyFormatter().format(input.loanAmount);
  final title =
      '$formatted · ${input.interestRate}% · ${input.tenureMonths}M';
  await ref.read(historyNotifierProvider.notifier).save(input, title: title);
  if (context.mounted) {
    NotificationService.show('Calculation saved to history');
  }
}

/// Shows a modal bottom sheet with export options for the current result.
void showCalculatorExportOptions({
  required BuildContext context,
  required WidgetRef ref,
  required EmiCalculation input,
  required EmiCalculationResult result,
  required GlobalKey captureKey,
}) {
  const exportService = ExportService();
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
                'Export Calculation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded),
                title: const Text('Export PDF'),
                subtitle: const Text('Professional document with summary'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final schedule = result.amortizationSchedule.cast<AmortizationMonth>();
                    final filePath = await exportService.generatePdf(
                      schedule: schedule,
                      loanAmount: result.effectiveLoanAmount,
                      totalInterest: result.totalInterest,
                      totalPayment: result.totalPayment,
                      emiAmount: result.emi,
                      interestRate: input.interestRate,
                      tenureMonths: input.tenureMonths,
                    );
                    await exportService.sharePdf(filePath);
                  } catch (e) {
                    if (context.mounted) {
                      _showError(context, 'PDF export failed: $e');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: const Text('Export CSV'),
                subtitle: const Text('Open in spreadsheet apps'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final csv = exportService.generateCsv(
                      schedule: result.amortizationSchedule.cast<AmortizationMonth>(),
                    );
                    await exportService.shareCsv(csv);
                  } catch (e) {
                    if (context.mounted) {
                      _showError(context, 'CSV export failed: $e');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_rounded),
                title: const Text('Share Image'),
                subtitle: const Text('Share as a screenshot'),
                onTap: () {
                  Navigator.pop(context);
                  _shareScreenshot(context, captureKey);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _shareScreenshot(BuildContext context, GlobalKey captureKey) async {
  try {
    final result = await ImageExportService.captureAndShare(
      captureKey: captureKey,
      fileName: 'emi_calculation',
      shareSubject: 'EMI Calculation',
    );
    if (result == null && context.mounted) {
      _showError(context, 'Unable to capture screenshot.');
    }
  } catch (e) {
    if (context.mounted) {
      _showError(context, 'Image export failed: $e');
    }
  }
}

void _showError(BuildContext context, String message) {
  if (context.mounted) {
    NotificationService.show(message);
  }
}
