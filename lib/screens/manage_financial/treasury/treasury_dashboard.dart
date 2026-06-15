// ============================================================
// treasury_dashboard.dart
// Screen  : Treasury Dashboard
// Role    : TREASURY
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../widgets/app_drawer.dart';
import 'student_payments_view.dart';
import 'fee_records.dart';

// ── Figma colours ────────────────────────────────────────────
const _kTeal       = Color(0xFF00BFA5); // AppBar
const _kGradStart  = Color(0xFF00A63E); // card gradient start
const _kGradEnd    = Color(0xFF008236); // card gradient end
const _kSubGreen   = Color(0xFFDCFCE7); // card label text
const _kYellow     = Color(0xFFFFF085); // pending amount
const _kDark       = Color(0xFF1E2939); // primary text
const _kGrey       = Color(0xFF4A5565); // secondary text
const _kWarnBg     = Color(0xFFFEFCE8); // banner bg
const _kWarnTitle  = Color(0xFF733E0A); // banner heading
const _kWarnBody   = Color(0xFFA65F00); // banner body
const _kIconGreen  = Color(0xFF00C950); // Student Payments icon bg
const _kIconBlue   = Color(0xFF2B7FFF); // Fee Records icon bg

// ── Shared shadow list ────────────────────────────────────────
const _kCardShadow = [
  BoxShadow(color: Color(0x19000000), blurRadius: 2,  offset: Offset(0, 1), spreadRadius: -1),
  BoxShadow(color: Color(0x19000000), blurRadius: 3,  offset: Offset(0, 1), spreadRadius:  0),
];

class TreasuryDashboardView extends StatefulWidget {
  const TreasuryDashboardView({super.key});

  @override
  State<TreasuryDashboardView> createState() => _TreasuryDashboardViewState();
}

class _TreasuryDashboardViewState extends State<TreasuryDashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<FinancialController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();
    final data = ctrl.dashboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: _kTeal,
        elevation: 0,
        title: const Text(
          'Treasury Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
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
      drawer: const AppDrawer(role: 'treasury'),

      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: _kTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ════════════════════════════════════════════
                  // SUMMARY CARD
                  // ════════════════════════════════════════════
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
                        // Title row
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.white, size: 32),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Treasury Office',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    height: 1.40,
                                  ),
                                ),
                                Text(
                                  'Financial Management',
                                  style: TextStyle(
                                    color: _kSubGreen,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Total Revenue row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Revenue',
                              style: TextStyle(
                                color: _kSubGreen,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            Text(
                              'RM ${data?.totalRevenue.toStringAsFixed(0) ?? '0'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Pending Collection row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Pending Collection',
                              style: TextStyle(
                                color: _kSubGreen,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            Text(
                              'RM ${data?.pendingCollection.toStringAsFixed(0) ?? '0'}',
                              style: const TextStyle(
                                color: _kYellow,
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════
                  // STATS ROW
                  // ════════════════════════════════════════════
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up,
                          iconColor: _kGradStart,
                          value: '${data?.collectionRate.toStringAsFixed(0) ?? '0'}%',
                          label: 'Collection',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_alt_outlined,
                          iconColor: _kIconBlue,
                          value: '${ctrl.paidCount}',
                          label: 'Paid',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.error_outline,
                          iconColor: Colors.red,
                          value: '${ctrl.outstandingCount}',
                          label: 'Pending',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════
                  // ALERT BANNER
                  // ════════════════════════════════════════════
                  if (ctrl.outstandingCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 16, left: 19, right: 16, bottom: 16),
                      decoration: ShapeDecoration(
                        color: _kWarnBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.error_outline,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Week 5 Deadline Approaching',
                                  style: TextStyle(
                                    color: _kWarnTitle,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ctrl.outstandingCount} students need to complete payment to avoid account blocking',
                                  style: const TextStyle(
                                    color: _kWarnBody,
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

                  const SizedBox(height: 20),

                  // ════════════════════════════════════════════
                  // SECTION TITLE
                  // ════════════════════════════════════════════
                  Row(
                    children: const [
                      Text(
                        '\$',
                        style: TextStyle(
                          color: _kGradStart,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Financial Management',
                        style: TextStyle(
                          color: _kDark,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ════════════════════════════════════════════
                  // NAV CARDS
                  // ════════════════════════════════════════════
                  _NavCard(
                    iconBg: _kIconGreen,
                    icon: Icons.credit_card,
                    title: 'Student Payments',
                    subtitle: 'View and manage student fee payments',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TreasuryStudentPaymentsView(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _NavCard(
                    iconBg: _kIconBlue,
                    icon: Icons.description_outlined,
                    title: 'Fee Records',
                    subtitle: 'Financial records and reports',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TreasuryFeeRecordsView(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
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
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Card ───────────────────────────────────────────────────
class _NavCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadows: _kCardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Solid coloured square icon
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: iconBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _kDark,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _kGrey,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(Icons.chevron_right, color: _kGrey, size: 20),
          ],
        ),
      ),
    );
  }
}
