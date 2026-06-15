// ============================================================
// student_financial_page.dart
// Screen  : Financial Page (main student screen)
// Role    : STUDENT
// Path    : screens/manage_financial/student/
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';
import '../../../widgets/app_drawer.dart';
import 'make_payment.dart';
import 'payment_history.dart';
import 'student_notifications.dart';

const kPurple = Color(0xFF7B2FBE);
const kPurpleLight = Color(0xFF9C4FE0);
const kGreen = Color(0xFF00C897);
const kRed = Color(0xFFFF4D4D);

class StudentFinancialPage extends StatefulWidget {
  final String studentId;
  const StudentFinancialPage({super.key, required this.studentId});

  @override
  State<StudentFinancialPage> createState() => _StudentFinancialPageState();
}

class _StudentFinancialPageState extends State<StudentFinancialPage> {
  @override
  void initState() {
    super.initState();
    final ctrl = context.read<FinancialController>();
    Future.microtask(() => ctrl.loadStudentFinancial(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();
    final data = ctrl.studentFinancial;

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
                builder: (_) =>
                    StudentNotificationsPage(studentId: widget.studentId),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
      drawer: const AppDrawer(role: 'student'),
      backgroundColor: Colors.white,
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : data == null
          ? Center(
              child: Text(
                ctrl.errorMessage ?? 'No data found.',
                style: const TextStyle(color: kRed),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Warning banner — only when outstanding > 0
                  if (data.totalOutstanding > 0) ...[
                    _PaymentBanner(
                      isOverdue: data.deadlineOverdue,
                      deadline: data.paymentDeadline,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Card 1 — purple: always visible
                  _BalanceCard(
                    outstanding: data.totalOutstanding,
                    breakdown: data.feeBreakdown,
                  ),
                  const SizedBox(height: 12),

                  // Card 2 — white: always visible
                  _ProgressCard(
                    paid: data.totalPaid,
                    total: data.feeBreakdown.total,
                    isOverdue: data.deadlineOverdue,
                    deadline: data.paymentDeadline,
                  ),
                  const SizedBox(height: 24),

                  // Pay Now button — only when outstanding > 0
                  if (data.totalOutstanding > 0) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentMakePaymentPage(
                              studentId: widget.studentId,
                              studentName: data.studentName,
                              semester: data.semester,
                              totalAmount: data.totalOutstanding,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Always show view payment history
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentPaymentHistoryPage(
                            studentId: widget.studentId,
                          ),
                        ),
                      ),
                      child: const Text(
                        'View payment history',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Payment Required banner ───────────────────────────────────
class _PaymentBanner extends StatelessWidget {
  final bool isOverdue;
  final String deadline;
  const _PaymentBanner({required this.isOverdue, required this.deadline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: kRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Required',
                  style: TextStyle(
                    color: kRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOverdue
                      ? 'Your $deadline deadline is overdue. Pay now to restore access.'
                      : 'Please settle your fees by $deadline to avoid account blocking',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 1: Outstanding balance + fee breakdown (purple) ──────
class _BalanceCard extends StatelessWidget {
  final double outstanding;
  final FeeBreakdown breakdown;

  const _BalanceCard({
    required this.outstanding,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPurple, kPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total outstanding balance',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'RM ${outstanding.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white38, height: 20),
          _FeeRow('Education fee', breakdown.educationFee),
          _FeeRow('Hostel Fee', breakdown.hostelFee),
          _FeeRow('Other fee', breakdown.otherFee),
          const Divider(color: Colors.white38, height: 16),
          _FeeRow('Total', breakdown.total, isBold: true),
        ],
      ),
    );
  }
}

// ── Card 2: Payment progress (white/light) ────────────────────
class _ProgressCard extends StatelessWidget {
  final double paid;
  final double total;
  final bool isOverdue;
  final String deadline;

  const _ProgressCard({
    required this.paid,
    required this.total,
    required this.isOverdue,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? paid / total : 0.0;
    final d = deadline.isNotEmpty
        ? deadline[0].toUpperCase() + deadline.substring(1)
        : deadline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment progress',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              Text(
                'RM ${paid.toStringAsFixed(2)} / RM ${total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOverdue ? '$d deadline : overdue' : '$d deadline',
            style: TextStyle(
              color: isOverdue ? Colors.red.shade400 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  const _FeeRow(this.label, this.amount, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
