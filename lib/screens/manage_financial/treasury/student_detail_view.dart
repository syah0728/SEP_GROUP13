// ============================================================
// student_detail_view.dart
// Screen  : Student Details
// Role    : TREASURY
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';
import '../../../services/session_service.dart';
import '../../../widgets/treasury_drawer.dart';

// ── Colours ───────────────────────────────────────────────────
const _kTeal   = Color(0xFF45C5C3);
const _kGreen  = Color(0xFF008236);
const _kRed    = Color(0xFFC10007);
const _kDark   = Color(0xFF1E2939);
const _kGrey   = Color(0xFF4A5565);

const _kCardShadow = [
  BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
  BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius:  0),
];

class TreasuryStudentDetailView extends StatefulWidget {
  final String studentId;
  const TreasuryStudentDetailView({super.key, required this.studentId});

  @override
  State<TreasuryStudentDetailView> createState() =>
      _TreasuryStudentDetailViewState();
}

class _TreasuryStudentDetailViewState
    extends State<TreasuryStudentDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<FinancialController>().loadStudentDetail(widget.studentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl    = context.watch<FinancialController>();
    final student = ctrl.selectedStudent;
    final history = ctrl.studentPayments;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: TreasuryDrawer(
        activePage: 'payments',
        onLogout: () {
          AppSession.clear();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      appBar: AppBar(
        backgroundColor: _kTeal,
        elevation: 0,
        title: const Text(
          'Student Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFB2C36),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),

      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: _kTeal))
          : student == null
              ? const Center(child: Text('Student not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Student Info Card ──────────────────
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(
                                          color: _kDark,
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.40,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        student.matric,
                                        style: const TextStyle(
                                          color: _kGrey,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: student.status == 'paid'
                                        ? const Color(0xFFDCFCE7)
                                        : student.status == 'partial'
                                            ? const Color(0xFFFFF3E0)
                                            : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    student.status == 'paid'
                                        ? 'Paid'
                                        : student.status == 'partial'
                                            ? 'Partial'
                                            : 'Outstanding',
                                    style: TextStyle(
                                      color: student.status == 'paid'
                                          ? _kGreen
                                          : student.status == 'partial'
                                              ? const Color(0xFFE65100)
                                              : _kRed,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Semester',
                              value: student.semester.isNotEmpty
                                  ? student.semester
                                  : 'Sem 2, 2025/2026',
                            ),
                            const SizedBox(height: 6),
                            _InfoRow(
                              label: 'Payment Due Date',
                              value: student.paymentDueDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(student.paymentDueDate!)
                                  : '2026-03-31',
                            ),
                            const SizedBox(height: 6),
                            _InfoRow(
                              label: 'Last Payment',
                              value: student.lastPayment != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(student.lastPayment!)
                                  : 'No payment yet',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Payment Summary ────────────────────
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Summary',
                              style: TextStyle(
                                color: _kDark,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _AmountRow(
                              label: 'Total Fees',
                              value: 'RM ${student.totalFees.toStringAsFixed(2)}',
                              valueColor: _kDark,
                            ),
                            const SizedBox(height: 8),
                            _AmountRow(
                              label: 'Amount Paid',
                              value: 'RM ${student.paid.toStringAsFixed(2)}',
                              valueColor: _kGreen,
                            ),
                            const SizedBox(height: 8),
                            _AmountRow(
                              label: 'Outstanding',
                              value: 'RM ${student.outstanding.toStringAsFixed(2)}',
                              valueColor: _kRed,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: student.totalFees > 0
                                          ? (student.paid / student.totalFees)
                                              .clamp(0.0, 1.0)
                                          : 0.0,
                                      backgroundColor: const Color(0xFFE5E7EB),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              _kGreen),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${student.totalFees > 0 ? (student.paid / student.totalFees * 100).toStringAsFixed(0) : 0}%',
                                  style: const TextStyle(
                                    color: _kGrey,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Fee Breakdown ──────────────────────
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fee Breakdown',
                              style: TextStyle(
                                color: _kDark,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FeeBreakdownRow(
                              label: 'Education Fee',
                              subtitle: 'Tuition and academic fees',
                              amount: 'RM ${student.feeBreakdown.educationFee.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 10),
                            _FeeBreakdownRow(
                              label: 'Hostel Fee',
                              subtitle: 'Accommodation charges',
                              amount: 'RM ${student.feeBreakdown.hostelFee.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 10),
                            _FeeBreakdownRow(
                              label: 'Others',
                              subtitle: 'Library, sports, facilities',
                              amount: 'RM ${student.feeBreakdown.otherFee.toStringAsFixed(2)}',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    color: _kDark,
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'RM ${student.totalFees.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _kDark,
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Payment History ────────────────────
                      const Text(
                        'Payment History',
                        style: TextStyle(
                          color: _kDark,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (history.isEmpty)
                        const Text(
                          'No payments recorded.',
                          style: TextStyle(color: _kGrey, fontFamily: 'Inter'),
                        )
                      else
                        ...history.map((p) => _HistoryTile(payment: p)),

                      const SizedBox(height: 20),

                      // ── Send Payment Reminder ──────────────
                      _ActionButton(
                        label: 'Send Payment Reminder',
                        icon: Icons.notifications_outlined,
                        color: _kTeal,
                        onPressed: () async {
                          await context
                              .read<FinancialController>()
                              .sendReminder(student.matric, student.name);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder sent to student'),
                                backgroundColor: _kGreen,
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── Block / Unblock ────────────────────
                      _ActionButton(
                        label: student.isBlocked
                            ? 'Unblock Student Access'
                            : 'Block Student Access',
                        icon: student.isBlocked
                            ? Icons.lock_open_outlined
                            : Icons.lock_outline,
                        color: student.isBlocked ? _kGreen : _kRed,
                        onPressed: () async {
                          await context
                              .read<FinancialController>()
                              .blockStudent(student.id, !student.isBlocked);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(student.isBlocked
                                    ? 'Student unblocked'
                                    : 'Student blocked'),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── Export Student Report ──────────────
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD1D5DC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.download_outlined,
                              size: 18, color: _kGrey),
                          label: const Text(
                            'Export Student Report',
                            style: TextStyle(
                              color: _kGrey,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Exporting report...')),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

// ── White Card wrapper ─────────────────────────────────────────
Widget _card({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadows: _kCardShadow,
    ),
    child: child,
  );
}

// ── Info Row ───────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _kGrey,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _kDark,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Amount Row ─────────────────────────────────────────────────
class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _AmountRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _kGrey,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Fee Breakdown Row ──────────────────────────────────────────
class _FeeBreakdownRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String amount;
  const _FeeBreakdownRow({
    required this.label,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _kDark,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: _kGrey,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            color: _kDark,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── History Tile ───────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final PaymentHistoryModel payment;
  const _HistoryTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: _kCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: _kGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: _kDark,
                    ),
                    children: [
                      const TextSpan(text: 'Payment Received • '),
                      TextSpan(
                        text: 'RM ${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(color: _kGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('yyyy-MM-dd').format(payment.date),
                  style: const TextStyle(
                    color: _kGrey,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Method: ${payment.method}',
                  style: const TextStyle(
                    color: _kGrey,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Ref: ${payment.reference}',
                  style: const TextStyle(
                    color: _kGrey,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
