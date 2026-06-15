import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/manage_financial/financial_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Monthly Report ──────────────────────────────────────────
  // Fetches all payments from Firestore, groups them by month,
  // generates a PDF and opens the share/print dialog.
  Future<void> exportMonthlyReport() async {
    final snap = await _db
        .collection('payments')
        .orderBy('createdAt', descending: false)
        .get();

    // Group payments by "MMMM yyyy" key
    final Map<String, List<Map<String, dynamic>>> byMonth = {};
    for (final doc in snap.docs) {
      final data = doc.data();
      DateTime date;
      final ts = data['createdAt'];
      date = ts != null ? (ts as Timestamp).toDate() : DateTime.now();
      final key = DateFormat('MMMM yyyy').format(date);
      byMonth.putIfAbsent(key, () => []).add(data);
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) {
          final rows = <pw.Widget>[
            pw.Text(
              'Monthly Fee Collection Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${DateFormat('d MMMM yyyy, hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
          ];

          if (byMonth.isEmpty) {
            rows.add(pw.Text('No payment records found.'));
          } else {
            for (final entry in byMonth.entries) {
              final monthLabel = entry.key;
              final payments  = entry.value;
              final total = payments.fold<double>(
                0, (s, p) => s + (p['totalAmount'] ?? 0).toDouble());

              rows.add(pw.Text(
                monthLabel,
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ));
              rows.add(pw.SizedBox(height: 4));
              rows.add(pw.Text(
                'Total Collected: RM ${total.toStringAsFixed(2)}   '
                'Transactions: ${payments.length}',
                style: const pw.TextStyle(fontSize: 10),
              ));
              rows.add(pw.SizedBox(height: 6));

              rows.add(pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(1.2),
                  2: const pw.FlexColumnWidth(1.8),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _cell('Student', bold: true),
                      _cell('Amount', bold: true),
                      _cell('Method', bold: true),
                      _cell('Reference', bold: true),
                    ],
                  ),
                  ...payments.map((p) => pw.TableRow(children: [
                    _cell('${p['studentName'] ?? ''}\n(${p['studentID'] ?? ''})'),
                    _cell('RM ${(p['totalAmount'] ?? 0).toStringAsFixed(2)}'),
                    _cell(p['paymentMethod'] ?? ''),
                    _cell(p['receiptNo'] ?? ''),
                  ])),
                ],
              ));
              rows.add(pw.SizedBox(height: 16));
            }
          }
          return rows;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'monthly_report_${DateFormat('yyyyMM').format(DateTime.now())}.pdf',
    );
  }

  // ── Semester Report ─────────────────────────────────────────
  // Fetches semester_summary + all payments, generates PDF.
  Future<void> exportSemesterReport() async {
    final summaryDoc = await _db.collection('semester_summary').doc('current').get();
    final summary = summaryDoc.data() ?? {};

    final snap = await _db
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .get();
    final payments = snap.docs.map((d) => d.data()).toList();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(
            'Semester Fee Collection Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Semester: ${summary['semester'] ?? '-'}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Generated: ${DateFormat('d MMMM yyyy, hh:mm a').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          pw.Text('Summary',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              _summaryRow('Total Revenue',
                  'RM ${(summary['totalRevenue'] ?? 0).toStringAsFixed(2)}'),
              _summaryRow('Pending Collection',
                  'RM ${(summary['pendingCollection'] ?? 0).toStringAsFixed(2)}'),
              _summaryRow('Collection Rate',
                  '${(summary['collectionRate'] ?? 0).toStringAsFixed(1)}%'),
              _summaryRow('Students Paid',   '${summary['totalPaid'] ?? 0}'),
              _summaryRow('Students Pending','${summary['totalPending'] ?? 0}'),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text('All Transactions',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),

          if (payments.isEmpty)
            pw.Text('No transactions found.',
                style: const pw.TextStyle(color: PdfColors.grey700))
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(1.8),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _cell('Student', bold: true),
                    _cell('Amount', bold: true),
                    _cell('Method', bold: true),
                  ],
                ),
                ...payments.map((p) => pw.TableRow(children: [
                  _cell('${p['studentName'] ?? ''}\n(${p['studentID'] ?? ''})'),
                  _cell('RM ${(p['totalAmount'] ?? 0).toStringAsFixed(2)}'),
                  _cell(p['paymentMethod'] ?? ''),
                ])),
              ],
            ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'semester_report_${DateFormat('yyyyMM').format(DateTime.now())}.pdf',
    );
  }

  // ── Student Report ──────────────────────────────────────────
  Future<void> exportStudentReport(String studentId) async {
    final studentDoc = await _db.collection('students').doc(studentId).get();
    final finDoc = await _db
        .collection('students')
        .doc(studentId)
        .collection('financial')
        .doc('current')
        .get();

    final paymentsSnap = await _db
        .collection('payments')
        .where('studentID', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();

    final studentData  = studentDoc.data() ?? {};
    final finData      = finDoc.data() ?? {};
    final payments     = paymentsSnap.docs.map((d) => d.data()).toList();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(
            'Student Financial Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: ${DateFormat('d MMMM yyyy, hh:mm a').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          pw.Text('Student Info',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              _summaryRow('Name',     studentData['studentName'] ?? '-'),
              _summaryRow('Matric',   finData['studentID'] ?? studentId),
              _summaryRow('Semester', finData['semester'] ?? '-'),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text('Financial Summary',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              _summaryRow('Total Fees',
                  'RM ${(finData['totalAmount'] ?? 0).toStringAsFixed(2)}'),
              _summaryRow('Paid',
                  'RM ${(finData['paidAmount'] ?? 0).toStringAsFixed(2)}'),
              _summaryRow('Outstanding',
                  'RM ${((finData['totalAmount'] ?? 0) - (finData['paidAmount'] ?? 0)).clamp(0, double.infinity).toStringAsFixed(2)}'),
              _summaryRow('Status', finData['paymentStatus'] ?? '-'),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text('Payment History',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),

          if (payments.isEmpty)
            pw.Text('No payment records found.',
                style: const pw.TextStyle(color: PdfColors.grey700))
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _cell('Date', bold: true),
                    _cell('Amount', bold: true),
                    _cell('Method', bold: true),
                    _cell('Reference', bold: true),
                  ],
                ),
                ...payments.map((p) {
                  final ts = p['createdAt'];
                  final date = ts != null
                      ? DateFormat('d MMM yyyy').format((ts as Timestamp).toDate())
                      : '-';
                  return pw.TableRow(children: [
                    _cell(date),
                    _cell('RM ${(p['totalAmount'] ?? 0).toStringAsFixed(2)}'),
                    _cell(p['paymentMethod'] ?? ''),
                    _cell(p['receiptNo'] ?? ''),
                  ]);
                }),
              ],
            ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'student_report_$studentId.pdf',
    );
  }

  // ── Individual Payment Receipt ──────────────────────────────
  Future<void> generatePaymentReceipt(PaymentHistoryModel payment) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) {
          final dateStr = DateFormat('d MMMM yyyy, hh:mm a').format(payment.date);
          final green = PdfColor.fromHex('#00C897');
          final purple = PdfColor.fromHex('#7B2FBE');

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(color: purple),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('UMPSA', style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    )),
                    pw.SizedBox(height: 4),
                    pw.Text('Student Academic Management System',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                    pw.SizedBox(height: 12),
                    pw.Text('PAYMENT RECEIPT', style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    )),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Receipt info
              _receiptRow('Receipt No.', payment.reference),
              _receiptRow('Date', dateStr),
              pw.SizedBox(height: 16),

              // Student info
              pw.Text('Student Details',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              _receiptRow('Student Name', payment.studentName),
              _receiptRow('Student ID', payment.studentId),
              _receiptRow('Semester', payment.semester),
              pw.SizedBox(height: 16),

              // Payment info
              pw.Text('Payment Details',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              _receiptRow('Payment Method', payment.method),
              _receiptRow('Payment Status', 'PAID'),
              pw.SizedBox(height: 16),

              // Amount
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F0FBF8'),
                  border: pw.Border.all(color: green, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Amount Paid',
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text('RM ${payment.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 16,
                        fontWeight: pw.FontWeight.bold, color: green)),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated receipt. No signature required.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'receipt_${payment.reference}_${payment.studentId}.pdf',
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  // Used inside Column (returns pw.Widget, not pw.TableRow)
  static pw.Widget _receiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700)),
          pw.Text(value,
            style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.TableRow _summaryRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ),
    ]);
  }
}
