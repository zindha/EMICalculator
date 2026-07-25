import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/comparison_result.dart';
import '../models/comparison_session.dart';

/// Service that handles exporting a comparison session to CSV and PDF and
/// sharing it.
class ComparisonExportService {
  /// Creates a [ComparisonExportService].
  const ComparisonExportService();

  /// Generates a CSV string from the given [session] and [result].
  String generateCsv({
    required ComparisonSession session,
    required ComparisonResult result,
  }) {
    final buffer = StringBuffer();

    // Metadata
    buffer.writeln('Loan Comparison');
    buffer.writeln('Title,${session.title}');
    buffer.writeln('Created,${session.createdAt.toIso8601String()}');
    buffer.writeln();

    // Header
    buffer.writeln(
      'Loan Name,Loan Amount,Interest Rate (%),Tenure (months),'
      'Processing Fee (%),Insurance,Down Payment,EMI,Total Interest,'
      'Total Payment',
    );

    // Rows
    for (final offer in session.offers) {
      final calculation = offer.calculation;
      final metrics = result.offers[offer.id];
      buffer.writeln(
        '${_escape(offer.name)},'
        '${calculation.loanAmount},'
        '${calculation.interestRate},'
        '${calculation.tenureMonths},'
        '${calculation.processingFee},'
        '${calculation.insurance},'
        '${calculation.downPayment},'
        '${metrics?.emi ?? ''},'
        '${metrics?.totalInterest ?? ''},'
        '${metrics?.totalPayment ?? ''}',
      );
    }

    return buffer.toString();
  }

  /// Generates a PDF document for the comparison and returns its file path.
  Future<String> generatePdf({
    required ComparisonSession session,
    required ComparisonResult result,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: ' ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(level: 0, text: session.title),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              // ignore: prefer_const_constructors
              cellStyle: pw.TextStyle(fontSize: 9),
              headers: [
                'Loan',
                'EMI',
                'Total Interest',
                'Total Payment',
                'Tenure',
              ],
              data: session.offers.map((offer) {
                final metrics = result.offers[offer.id];
                return [
                  offer.name,
                  formatter.format(metrics?.emi ?? 0),
                  formatter.format(metrics?.totalInterest ?? 0),
                  formatter.format(metrics?.totalPayment ?? 0),
                  '${metrics?.tenureMonths ?? 0} months',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 24),
            pw.Header(level: 1, text: 'Highlights'),
            pw.Bullet(
              text:
                  'Lowest EMI: ${result.lowestEmiOfferId != null ? result.offers[result.lowestEmiOfferId!]!.offer.name : '—'}',
            ),
            pw.Bullet(
              text:
                  'Lowest Interest: ${result.lowestInterestOfferId != null ? result.offers[result.lowestInterestOfferId!]!.offer.name : '—'}',
            ),
            pw.Bullet(
              text:
                  'Shortest Tenure: ${result.shortestTenureOfferId != null ? result.offers[result.shortestTenureOfferId!]!.offer.name : '—'}',
            ),
            pw.Bullet(
              text:
                  'Lowest Total Payment: ${result.lowestTotalPaymentOfferId != null ? result.offers[result.lowestTotalPaymentOfferId!]!.offer.name : '—'}',
            ),
            pw.Bullet(
              text:
                  'Best Overall Value: ${result.bestOverallOfferId != null ? result.offers[result.bestOverallOfferId!]!.offer.name : '—'}',
            ),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/loan_comparison.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  /// Saves the [csvContent] to a temporary file and triggers the native
  /// share sheet.
  Future<void> shareCsv(String csvContent) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/loan_comparison.csv';
    final file = File(filePath);
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Loan Comparison',
    );
  }

  /// Shares the PDF at [filePath] via the native share sheet.
  Future<void> sharePdf(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Loan Comparison',
    );
  }

  String _escape(String value) {
    if (value.contains(',') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
