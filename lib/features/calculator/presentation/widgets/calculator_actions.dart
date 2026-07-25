import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../export/services/export_service.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../domain/models/amortization_month.dart';
import '../../domain/models/emi_calculation.dart';
import '../providers/calculator_provider.dart';

/// Captures the widget rendered inside [boundary] as a PNG image, saves it
/// to a temporary file, and returns the file path.
Future<String> captureAndSaveImage(RenderRepaintBoundary boundary) async {
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData?.buffer.asUint8List();

  if (bytes == null) {
    throw const ExportException('Failed to capture image.');
  }

  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/emi_calculation.png';
  final file = File(filePath);
  await file.writeAsBytes(bytes);
  return filePath;
}

/// Saves the current calculation to history.
Future<void> saveCalculationToHistory(
  BuildContext context,
  WidgetRef ref,
  EmiCalculation input,
) async {
  final title =
      '₹${input.loanAmount.toStringAsFixed(0)} · ${input.interestRate}% · ${input.tenureMonths}M';
  await ref.read(historyNotifierProvider.notifier).save(input, title: title);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved to history')),
    );
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export Calculation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded),
                title: const Text('Export PDF'),
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: const Text('Export CSV'),
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.image_rounded),
                title: const Text('Share Image'),
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
    final boundary = captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      _showError(context, 'Unable to capture screenshot.');
      return;
    }
    final filePath = await captureAndSaveImage(boundary);
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'EMI Calculation',
    );
  } catch (e) {
    if (context.mounted) {
      _showError(context, 'Image export failed: $e');
    }
  }
}

void _showError(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
