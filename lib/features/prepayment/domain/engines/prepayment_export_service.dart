import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/prepayment_input.dart';
import '../models/prepayment_result.dart';
import '../models/prepayment_strategy.dart';

/// Service that handles exporting prepayment plans as PDF, CSV, and images,
/// and sharing them via the native share sheet.
class PrepaymentExportService {
  /// Creates a [PrepaymentExportService].
  const PrepaymentExportService();

  /// Generates a CSV string representing the prepayment plan and its result.
  String generateCsv({
    required PrepaymentInput input,
    required PrepaymentResult result,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Prepayment Plan');
    buffer.writeln('Strategy,${input.strategy.label}');
    buffer.writeln();

    buffer.writeln('Original Loan');
    buffer.writeln(
      'Loan Amount,Interest Rate (%),Tenure (months),EMI,Total Interest,Total Payment',
    );
    buffer.writeln(
      '${input.baseCalculation.loanAmount},'
      '${input.baseCalculation.interestRate},'
      '${input.baseCalculation.tenureMonths},'
      '${result.originalEmi.toStringAsFixed(2)},'
      '${result.originalTotalInterest.toStringAsFixed(2)},'
      '${result.originalTotalPayment.toStringAsFixed(2)}',
    );
    buffer.writeln();

    buffer.writeln('Updated Loan');
    buffer.writeln(
      'EMI,Total Interest,Total Payment,Interest Saved,Money Saved,Months Saved',
    );
    buffer.writeln(
      '${result.updatedEmi.toStringAsFixed(2)},'
      '${result.updatedTotalInterest.toStringAsFixed(2)},'
      '${result.updatedTotalPayment.toStringAsFixed(2)},'
      '${result.interestSaved.toStringAsFixed(2)},'
      '${result.moneySaved.toStringAsFixed(2)},'
      '${result.monthsSaved}',
    );
    buffer.writeln();

    buffer.writeln('Amortization Schedule');
    buffer.writeln(
      'Month,Opening Balance,EMI,Principal Paid,Interest Paid,Closing Balance,Total Paid',
    );
    for (final entry in result.updatedSchedule) {
      buffer.writeln(
        '${entry.monthNumber},'
        '${entry.openingBalance.toStringAsFixed(2)},'
        '${entry.emiAmount.toStringAsFixed(2)},'
        '${entry.principalPaid.toStringAsFixed(2)},'
        '${entry.interestPaid.toStringAsFixed(2)},'
        '${entry.closingBalance.toStringAsFixed(2)},'
        '${entry.totalPaidSoFar.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }

  /// Generates a PDF document summarizing the prepayment plan and its result,
  /// and returns the path to the saved file.
  Future<String> generatePdf({
    required String title,
    required PrepaymentInput input,
    required PrepaymentResult result,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(level: 0, text: title),
          pw.SizedBox(height: 8),
          pw.Text(
            'Strategy: ${input.strategy.label}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 24),
          pw.Header(level: 1, text: 'Original Loan'),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Parameter', 'Value'],
            data: [
              ['Loan Amount', formatter.format(input.baseCalculation.loanAmount)],
              ['Interest Rate', '${input.baseCalculation.interestRate.toStringAsFixed(1)}%'],
              ['Tenure', '${input.baseCalculation.tenureMonths} months'],
              ['EMI', formatter.format(result.originalEmi)],
              ['Total Interest', formatter.format(result.originalTotalInterest)],
              ['Total Payment', formatter.format(result.originalTotalPayment)],
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Header(level: 1, text: 'Updated Loan'),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Parameter', 'Value'],
            data: [
              ['EMI', formatter.format(result.updatedEmi)],
              ['Total Interest', formatter.format(result.updatedTotalInterest)],
              ['Total Payment', formatter.format(result.updatedTotalPayment)],
              ['Interest Saved', formatter.format(result.interestSaved)],
              ['Money Saved', formatter.format(result.moneySaved)],
              ['Months Saved', '${result.monthsSaved}'],
              [
                'Completion Date',
                '${result.completionDate.day}/${result.completionDate.month}/${result.completionDate.year}'
              ],
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Header(level: 1, text: 'Amortization Schedule'),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            headers: [
              'Month',
              'Opening',
              'EMI',
              'Principal',
              'Interest',
              'Closing',
              'Total Paid',
            ],
            data: result.updatedSchedule.map((entry) {
              return [
                entry.monthNumber.toString(),
                formatter.format(entry.openingBalance),
                formatter.format(entry.emiAmount),
                formatter.format(entry.principalPaid),
                formatter.format(entry.interestPaid),
                formatter.format(entry.closingBalance),
                formatter.format(entry.totalPaidSoFar),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/prepayment_plan.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  /// Saves the [csvContent] to a temporary file and triggers the native share sheet.
  Future<void> shareCsv(String csvContent) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/prepayment_plan.csv';
    final file = File(filePath);
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Prepayment Plan',
    );
  }

  /// Shares the PDF at [filePath] via the native share sheet.
  Future<void> sharePdf(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Prepayment Plan',
    );
  }

  /// Captures the widget rendered inside [boundary] as a PNG image, saves
  /// it to a temporary file, and returns the file path.
  Future<String> generateImage(RenderRepaintBoundary boundary) async {
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();

    if (bytes == null) {
      throw const ExportException('Failed to capture image.');
    }

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/prepayment_plan.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Shares the image at [filePath] via the native share sheet.
  Future<void> shareImage(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Prepayment Plan',
    );
  }
}

/// Exception thrown when an export operation fails.
class ExportException implements Exception {
  /// Creates an [ExportException] with the given [message].
  const ExportException(this.message);

  /// Description of what went wrong.
  final String message;

  @override
  String toString() => 'ExportException: $message';
}
