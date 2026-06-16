// ============================================================
// student_payments_view.dart
// Screen  : Student Payments List
// Role    : TREASURY
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';
import '../../../widgets/treasury_drawer.dart';
import '../../../services/session_service.dart';
import 'student_detail_view.dart';

// ── Figma colours ─────────────────────────────────────────────
const _kTeal        = Color(0xFF45C5C3);
const _kDark        = Color(0xFF1E2939);
const _kGrey        = Color(0xFF4A5565);
const _kBg          = Color(0xFFF9FAFB);
const _kGreen       = Color(0xFF008236);
const _kGreenLight  = Color(0xFFDCFCE7);
const _kRed         = Color(0xFFC10007);
const _kRedDark     = Color(0xFF82181A);
const _kRedLight    = Color(0xFFFEF2F2);
const _kRedBorder   = Color(0xFFFFC9C9);
const _kFilterBg    = Color(0xFFF3F4F6);

const _kCardShadow = [
  BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
  BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius:  0),
];

class TreasuryStudentPaymentsView extends StatefulWidget {
  const TreasuryStudentPaymentsView({super.key});

  @override
  State<TreasuryStudentPaymentsView> createState() =>
      _TreasuryStudentPaymentsViewState();
}

class _TreasuryStudentPaymentsViewState
    extends State<TreasuryStudentPaymentsView> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<FinancialController>().loadAllStudents();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();

    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _kTeal,
        elevation: 0,
        title: const Text(
          'Student Payments',
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
      drawer: TreasuryDrawer(
        activePage: 'payments',
        onLogout: () {
          AppSession.clear();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              children: [
                // ── Alert Banner ────────────────────────────────
                if (ctrl.outstandingCount > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: _kRedLight,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 0.89, color: _kRedBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.warning_amber_rounded,
                              color: _kRed, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Week 5 Deadline Alert',
                                style: TextStyle(
                                  color: _kRedDark,
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.50,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ctrl.outstandingCount} students with outstanding fees are at or past Week 5 deadline',
                                style: const TextStyle(
                                  color: _kRed,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Stats Row ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_outline,
                        iconColor: _kGreen,
                        value: '${ctrl.paidCount}',
                        label: 'Paid',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timelapse,
                        iconColor: Colors.orange,
                        value: '${ctrl.partialCount}',
                        label: 'Partial',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.error_outline,
                        iconColor: _kRed,
                        value: '${ctrl.outstandingCount}',
                        label: 'Outstanding',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Search Bar ──────────────────────────────────
                Container(
                  height: 50,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.89, color: Color(0xFFD1D5DC)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (q) =>
                        context.read<FinancialController>().searchStudents(q),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      color: _kDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search by name or matric...',
                      hintStyle: TextStyle(
                        color: Color(0x7F0A0A0A),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(Icons.search, color: _kGrey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Filter Tabs ─────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'All',
                        icon: Icons.filter_list,
                        active: ctrl.studentFilter == 'All',
                        onTap: () => context
                            .read<FinancialController>()
                            .setStudentFilter('All'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Paid',
                        active: ctrl.studentFilter == 'Paid',
                        onTap: () => context
                            .read<FinancialController>()
                            .setStudentFilter('Paid'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Partial',
                        active: ctrl.studentFilter == 'Partial',
                        onTap: () => context
                            .read<FinancialController>()
                            .setStudentFilter('Partial'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Outstanding',
                        active: ctrl.studentFilter == 'Outstanding',
                        onTap: () => context
                            .read<FinancialController>()
                            .setStudentFilter('Outstanding'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Student List ────────────────────────────────
                if (ctrl.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: _kTeal),
                    ),
                  )
                else if (ctrl.allStudents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No students found.',
                        style: TextStyle(color: _kGrey, fontFamily: 'Inter'),
                      ),
                    ),
                  )
                else
                  ...ctrl.allStudents.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StudentCard(student: s),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: _kCardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _kDark,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: _kGrey,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Tab ─────────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: ShapeDecoration(
          color: active ? _kTeal : _kFilterBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: active ? Colors.white : _kGrey, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : _kGrey,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student Card ───────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final StudentSummaryModel student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final isPaid        = student.status == 'paid';
    final isPartial     = student.status == 'partial';
    final isOutstanding = student.status == 'outstanding';
    final progress      = student.totalFees > 0
        ? (student.paid / student.totalFees).clamp(0.0, 1.0)
        : 0.0;
    final lastPayStr = student.lastPayment != null
        ? 'Last payment: ${DateFormat('d MMMM yyyy').format(student.lastPayment!)}'
        : student.paid > 0
            ? 'Payment recorded'
            : 'No payment yet';

    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: _kCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name + badges ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    student.name,
                    style: const TextStyle(
                      color: _kDark,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    if (student.isWeek5) ...[
                      _StatusBadge(
                        label: 'Week 5',
                        icon: Icons.warning_amber_rounded,
                        bg: const Color(0xFFFFF3CD),
                        fg: const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (student.isBlocked) ...[
                      _StatusBadge(
                        label: 'Blocked',
                        icon: Icons.lock_outline,
                        bg: const Color(0xFFFFE4E6),
                        fg: const Color(0xFF9F1239),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (isPaid)
                      _StatusBadge(
                        label: 'Paid',
                        icon: Icons.check_circle_outline,
                        bg: _kGreenLight,
                        fg: _kGreen,
                      )
                    else if (isPartial)
                      _StatusBadge(
                        label: 'Partial',
                        icon: Icons.timelapse,
                        bg: const Color(0xFFFFF3E0),
                        fg: Colors.orange,
                      )
                    else if (isOutstanding)
                      _StatusBadge(
                        label: 'Outstanding',
                        icon: Icons.error_outline,
                        bg: const Color(0xFFFFE4E6),
                        fg: _kRed,
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 2),

            // ── Matric ────────────────────────────────────────
            Text(
              student.matric,
              style: const TextStyle(
                color: _kGrey,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),

            const SizedBox(height: 12),

            // ── Fee Rows ──────────────────────────────────────
            _FeeRow(
              label: 'Total Fees:',
              value: 'RM ${student.totalFees.toStringAsFixed(2)}',
              valueColor: _kDark,
            ),
            const SizedBox(height: 8),
            _FeeRow(
              label: 'Paid:',
              value: 'RM ${student.paid.toStringAsFixed(2)}',
              valueColor: _kGreen,
            ),
            if (student.outstanding > 0) ...[
              const SizedBox(height: 8),
              _FeeRow(
                label: 'Outstanding:',
                value: 'RM ${student.outstanding.toStringAsFixed(2)}',
                valueColor: _kRed,
              ),
            ],

            const SizedBox(height: 12),

            // ── Progress Bar ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 8),

            // ── Last Payment ──────────────────────────────────
            Text(
              lastPayStr,
              style: const TextStyle(
                color: _kGrey,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 12),

            // ── Action Buttons ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TreasuryStudentDetailView(
                            studentId: student.matric,
                          ),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isPaid) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: student.isBlocked
                            ? _kGreen
                            : _kRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: () => context
                          .read<FinancialController>()
                          .blockStudent(student.id, !student.isBlocked),
                      icon: Icon(
                        student.isBlocked
                            ? Icons.lock_open_outlined
                            : Icons.lock_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(
                        student.isBlocked ? 'Unblock' : 'Block',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fee Row ────────────────────────────────────────────────────
class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _FeeRow({
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
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}
