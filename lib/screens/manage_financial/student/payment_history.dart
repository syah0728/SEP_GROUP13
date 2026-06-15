// ============================================================
// student_payment_history_page.dart
// Screen  : Payment History
// Role    : STUDENT
// Path    : screens/manage_financial/student/
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';
import '../../../services/report_services.dart';
import 'student_notifications.dart';

const kPurple = Color(0xFF7B2FBE);
const kGreen = Color(0xFF00C897);

class StudentPaymentHistoryPage extends StatefulWidget {
  final String studentId;
  const StudentPaymentHistoryPage({super.key, required this.studentId});

  @override
  State<StudentPaymentHistoryPage> createState() =>
      _StudentPaymentHistoryPageState();
}

class _StudentPaymentHistoryPageState extends State<StudentPaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<FinancialController>().loadPaymentHistory(
        widget.studentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();
    final history = ctrl.paymentHistory;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPurple,
        title: const Text('Financial', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentNotificationsPage(studentId: widget.studentId),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),

      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text(
                    'Payment History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? const Center(child: Text('No payment records found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: history.length,
                          itemBuilder: (_, i) =>
                              _HistoryCard(payment: history[i]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final PaymentHistoryModel payment;
  const _HistoryCard({required this.payment});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _downloading = false;

  Future<void> _downloadReceipt() async {
    setState(() => _downloading = true);
    try {
      await ReportService().generatePaymentReceipt(widget.payment);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate receipt: $e'),
            backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy').format(widget.payment.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: kGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.payment.semester,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Text(
                'RM ${widget.payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('Method: ${widget.payment.method}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('Reference: ${widget.payment.reference}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: _downloading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download, size: 16),
              label: Text(_downloading ? 'Generating...' : 'Download Receipt'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _downloading ? null : _downloadReceipt,
            ),
          ),
        ],
      ),
    );
  }
}
