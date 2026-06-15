// screens/manage_cocurriculum/validate_claim.dart
// Adab staff screen: review, approve, or reject student credit claims.
// Shows three tabs: Pending / Approved / Rejected.
// Theme: orange (AppColors.primary) header + white body.

import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../../models/manage_cocurriculum/claim.dart';
import '../../../widgets/adab_sidebar.dart';
import '../../../utils/app_colors.dart';

class ValidateClaimsScreen extends StatefulWidget {
  const ValidateClaimsScreen({super.key});

  @override
  State<ValidateClaimsScreen> createState() => ValidateClaimsScreenState();
}

class ValidateClaimsScreenState extends State<ValidateClaimsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    service.migrateClaimsIfNeeded();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // Popup showing full claim details with optional Approve/Reject actions
  Future<void> showClaimDetails(ClaimModel claim,
      {required bool showActions}) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Claim Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Student',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(claim.studentName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(claim.matricNumber,
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              const Text('Module',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              ...claim.modules.map((m) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(m, style: const TextStyle(fontSize: 14)),
                  )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Marks',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(claim.marks,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grade',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(claim.grade,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Submitted Date',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(claim.submittedDate,
                  style: const TextStyle(fontSize: 14)),
              if (claim.status == 'rejected' &&
                  claim.rejectReason.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Rejection Reason',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(claim.rejectReason,
                      style: const TextStyle(color: AppColors.danger)),
                ),
              ],
              const SizedBox(height: 24),
              if (showActions) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await service.approveClaim(claim.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Claim approved successfully')),
                            );
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final reason = await showRejectDialog();
                          if (reason != null && reason.isNotEmpty) {
                            await service.rejectClaim(claim.id, reason);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Claim rejected')),
                              );
                              setState(() {});
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Claim'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StreamBuilder<int>(
        stream: service.getPendingClaimsCount(),
        builder: (context, snapshot) => AdabSidebar(
          activePage: 'claims',
          pendingClaimsCount: snapshot.data ?? 0,
          onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Orange header
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => scaffoldKey.currentState?.openDrawer(),
                          child: const Icon(Icons.menu,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text("Validate Claims",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.notifications_none, color: Colors.white),
                        SizedBox(width: 12),
                        Icon(Icons.person_outline, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              // Live stats: Pending / Approved / Rejected counts
              StreamBuilder<Map<String, int>>(
                stream: getStatsStream(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ??
                      {'pending': 0, 'approved': 0, 'rejected': 0};
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        statCard("Pending", stats['pending']!, Icons.pending,
                            AppColors.warning),
                        const SizedBox(width: 12),
                        statCard("Approved", stats['approved']!,
                            Icons.check_circle, AppColors.success),
                        const SizedBox(width: 12),
                        statCard("Rejected", stats['rejected']!, Icons.cancel,
                            AppColors.danger),
                      ],
                    ),
                  );
                },
              ),
              // Tab selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tabs: const [
                    Tab(text: "Pending"),
                    Tab(text: "Approved"),
                    Tab(text: "Rejected"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    buildClaimList(status: 'pending', showActions: true),
                    buildClaimList(status: 'approved', showActions: false),
                    buildClaimList(status: 'rejected', showActions: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Single stream derived from getClaims() — avoids multiple Firestore listeners
  Stream<Map<String, int>> getStatsStream() {
    return service.getClaims().map((claims) => {
          'pending': claims.where((c) => c.status == 'pending').length,
          'approved': claims.where((c) => c.status == 'approved').length,
          'rejected': claims.where((c) => c.status == 'rejected').length,
        });
  }

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(value.toString(),
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF4A5565))),
          ],
        ),
      ),
    );
  }

  Widget buildClaimList({required String status, required bool showActions}) {
    return StreamBuilder<List<ClaimModel>>(
      stream: service.getClaims(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final claims =
            snapshot.data!.where((c) => c.status == status).toList();
        if (claims.isEmpty) {
          return Center(
              child: Text('No $status claims.',
                  style: const TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: claims.length,
          itemBuilder: (context, index) {
            final c = claims[index];
            return InkWell(
              onTap: () => showClaimDetails(c, showActions: showActions),
              borderRadius: BorderRadius.circular(10),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.studentName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(c.matricNumber,
                                    style: const TextStyle(
                                        color: Color(0xFF4A5565),
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                          if (showActions)
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () =>
                                  showClaimDetails(c, showActions: true),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Color(0xFF4A5565)),
                          const SizedBox(width: 8),
                          Text('Submitted: ${c.submittedDate}',
                              style: const TextStyle(
                                  color: Color(0xFF4A5565), fontSize: 14)),
                        ],
                      ),
                      if (status == 'rejected' &&
                          c.rejectReason.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Reason: ${c.rejectReason}',
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 14)),
                      ],
                      if (showActions) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await service.approveClaim(c.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Claim approved successfully')),
                                    );
                                    setState(() {});
                                  }
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final reason = await showRejectDialog();
                                  if (reason != null && reason.isNotEmpty) {
                                    await service.rejectClaim(c.id, reason);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Claim rejected')));
                                      setState(() {});
                                    }
                                  }
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(
                                      color: AppColors.danger),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}