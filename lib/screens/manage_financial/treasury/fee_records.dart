// ============================================================
// fee_records.dart
// Screen  : Fee Records
// Role    : TREASURY
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';
import '../../../widgets/treasury_drawer.dart';
import '../../../services/session_service.dart';

// ── Colours ───────────────────────────────────────────────────
const _kTeal       = Color(0xFF45C5C3);
const _kGradStart  = Color(0xFF00A63E);
const _kGradEnd    = Color(0xFF008236);
const _kGreen      = Color(0xFF008236);
const _kYellow     = Color(0xFFFFF085);
const _kSubGreen   = Color(0xFFDCFCE7);
const _kDark       = Color(0xFF1E2939);
const _kGrey       = Color(0xFF4A5565);
const _kAmber      = Color(0xFFFF8C00);

const _kCardShadow = [
  BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
  BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius:  0),
];

class TreasuryFeeRecordsView extends StatefulWidget {
  const TreasuryFeeRecordsView({super.key});

  @override
  State<TreasuryFeeRecordsView> createState() => _TreasuryFeeRecordsViewState();
}

class _TreasuryFeeRecordsViewState extends State<TreasuryFeeRecordsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<FinancialController>().loadFeeRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl       = context.watch<FinancialController>();
    final summary    = ctrl.dashboard;
    final records    = ctrl.monthlyRecords;
    final txList     = ctrl.recentTransactions;
    final isExporting = ctrl.isExporting;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: _kTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fee Records',
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
        activePage: 'fee-records',
        onLogout: () {
          AppSession.clear();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),

      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: _kTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Semester Summary Card ────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_kGradStart, _kGradEnd],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      shadows: const [
                        BoxShadow(color: Color(0x19000000), blurRadius: 6,  offset: Offset(0, 4),  spreadRadius: -4),
                        BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Semester label
                        Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              summary?.semester.isNotEmpty == true
                                  ? summary!.semester
                                  : '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Total Revenue
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Revenue',
                              style: TextStyle(
                                color: _kSubGreen,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'RM ${summary?.totalRevenue.toStringAsFixed(0) ?? '0'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Pending Collection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pending Collection',
                              style: TextStyle(
                                color: _kSubGreen,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'RM ${summary?.pendingCollection.toStringAsFixed(0) ?? '0'}',
                              style: const TextStyle(
                                color: _kYellow,
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Collection Rate label + bar + %
                        const Text(
                          'Collection Rate',
                          style: TextStyle(
                            color: _kSubGreen,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                ((summary?.collectionRate ?? 0) / 100)
                                    .clamp(0.0, 1.0),
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${summary?.collectionRate.toStringAsFixed(0) ?? '0'}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Metric Cards Row ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.trending_up,
                          iconColor: _kTeal,
                          value: '${summary?.collectionRate.toStringAsFixed(0) ?? '0'}%',
                          label: 'Payment Rate',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.attach_money,
                          iconColor: const Color(0xFF2B7FFF),
                          value: () {
                            final total = summary?.totalRevenue ?? 0;
                            final count = summary?.totalPaid ?? 0;
                            if (count == 0) return 'RM 0';
                            return 'RM ${(total / count).toStringAsFixed(0)}';
                          }(),
                          label: 'Avg per Student',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Monthly Collection ───────────────────────
                  const Text(
                    'Monthly Collection',
                    style: TextStyle(
                      color: _kDark,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No monthly records found.',
                        style: TextStyle(color: _kGrey, fontFamily: 'Inter'),
                      ),
                    )
                  else
                    ...records.map(
                      (r) => _MonthlyCard(
                        month: '${r.month} ${r.year}',
                        collected: r.collected,
                        pending: r.pending,
                        studentsPaid: r.studentsPaid,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ── Recent Transactions ──────────────────────
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: _kDark,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (txList.isEmpty)
                    const Text(
                      'No recent transactions.',
                      style:
                          TextStyle(color: _kGrey, fontFamily: 'Inter'),
                    )
                  else
                    ...txList.map((tx) => _TxTile(tx: tx)),

                  const SizedBox(height: 24),

                  // ── Export Monthly Report ────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.download_outlined,
                              color: Colors.white, size: 18),
                      label: const Text(
                        'Export Monthly Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: isExporting
                          ? null
                          : () => ctrl.exportMonthlyReport(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Export Semester Report ───────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.download_outlined,
                              color: Colors.white, size: 18),
                      label: const Text(
                        'Export Semester Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: isExporting
                          ? null
                          : () => ctrl.exportSemesterReport(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ── Metric Card ────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: _kCardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _kGrey,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Monthly Card ───────────────────────────────────────────────
class _MonthlyCard extends StatelessWidget {
  final String month;
  final double collected;
  final double pending;
  final int studentsPaid;

  const _MonthlyCard({
    required this.month,
    required this.collected,
    required this.pending,
    required this.studentsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final total    = collected + pending;
    final progress = total > 0 ? (collected / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: _kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: _kTeal, size: 16),
              const SizedBox(width: 8),
              Text(
                month,
                style: const TextStyle(
                  color: _kDark,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Collected
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collected',
                style: TextStyle(
                  color: _kGrey,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                'RM ${collected.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _kDark,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Pending
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending',
                style: TextStyle(
                  color: _kGrey,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                'RM ${pending.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _kAmber,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Students Paid
          Text(
            'Students Paid       $studentsPaid',
            style: const TextStyle(
              color: _kGrey,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Tile ───────────────────────────────────────────
class _TxTile extends StatelessWidget {
  final RecentTransactionModel tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('d MMMM yyyy, hh:mm a').format(tx.date);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.studentName} (${tx.studentId})',
                  style: const TextStyle(
                    color: _kDark,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: _kGrey,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Method: ${tx.method}',
                  style: const TextStyle(
                    color: _kGrey,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Reference: ${tx.reference}',
                  style: const TextStyle(
                    color: _kGrey,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Text(
            'RM ${tx.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: _kGreen,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
