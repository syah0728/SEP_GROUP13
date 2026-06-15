import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/std_sidebar.dart';
import '../../../services/firebase_services.dart';

class ClaimCreditScreen extends StatefulWidget {
  const ClaimCreditScreen({super.key});

  @override
  State<ClaimCreditScreen> createState() => ClaimCreditScreenState();
}

class ClaimCreditScreenState extends State<ClaimCreditScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();

  final String studentName = "Ahmad Imran";
  final String matricNumber = "CD210145";

  static const Color purplePrimary = Color(0xFFAB43FE);
  static const int requiredPoints = 8;
  static const int pointsPerModule = 2; // each completed module gives 2 CATS

  // In a real app, this data would come from Firestore.
  // For demo, we assume these modules are completed (attended + passed).
  // Each completed module gives pointsPerModule.
  final List<Map<String, dynamic>> completedModules = [
    {'name': 'Memanah', 'date': '15 April 2026', 'points': pointsPerModule},
    {
      'name': '3D Design + 3D Printing',
      'date': '20 April 2026',
      'points': pointsPerModule
    },
    {
      'name': 'Pengurusan Majlis',
      'date': '30 April 2026',
      'points': pointsPerModule
    },
    {
      'name': 'Psychological First Aid',
      'date': '28 April 2026',
      'points': pointsPerModule
    },
  ];

  int get totalEarnedPoints =>
      completedModules.fold(0, (sum, m) => sum + (m['points'] as int));
  bool get canSubmit => totalEarnedPoints >= requiredPoints;
  int get creditsEarned => totalEarnedPoints ~/ 4; // 4 CATS = 1 credit

  Future<void> submitClaim() async {
    if (!canSubmit) return;

    // Prepare claim data for Firestore
    final claimData = {
      'studentName': studentName,
      'matricNumber': matricNumber,
      'submittedDate': DateTime.now().toLocal().toString().split(' ')[0],
      'status': 'pending',
      'modules': completedModules.map((m) => m['name'] as String).toList(),
      'marks': 'Auto-approved', // or calculated average
      'grade': 'N/A',
      'rejectReason': '',
      'totalPoints': totalEarnedPoints,
    };

    try {
      // Add claim to Firestore
      await FirebaseFirestore.instance.collection('claims').add(claimData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Credit claim submitted successfully! Pending approval.'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally, disable further submissions or navigate away
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit claim: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StudentSidebar(
        activePage: 'claim',
        studentName: studentName,
        matricNumber: matricNumber,
        onLogout: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Purple header
              Container(
                color: purplePrimary,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => scaffoldKey.currentState?.openDrawer(),
                      child:
                          const Icon(Icons.menu, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Text("Claim Credit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eligibility badge (changes based on points)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: canSubmit
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: canSubmit
                                  ? const Color(0xFFA5D6A7)
                                  : const Color(0xFFFFCC80)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                canSubmit ? Icons.verified : Icons.info_outline,
                                color: canSubmit ? Colors.green : Colors.orange,
                                size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    canSubmit
                                        ? "Ready to Submit! âœ“"
                                        : "Earn More Points",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: canSubmit
                                            ? Colors.green
                                            : Colors.orange),
                                  ),
                                  Text(
                                    canSubmit
                                        ? "You have earned $totalEarnedPoints / $requiredPoints CATS points. You can now submit your credit claim."
                                        : "You have earned $totalEarnedPoints / $requiredPoints CATS points. Complete more modules to reach $requiredPoints points and claim your credits.",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Completed modules list
                      const Text("Completed Modules",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text(
                          "Automatically awarded CATS points for each passed module.",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: completedModules.length,
                        itemBuilder: (context, index) {
                          final module = completedModules[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(module['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(module['date'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text("+${module['points']} pts",
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // CATS Points Progress Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text("CATS Points Progress",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text("Earned",
                                        style: TextStyle(fontSize: 14)),
                                    Text("$totalEarnedPoints/$requiredPoints",
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text("Credits Earned",
                                        style: TextStyle(fontSize: 14)),
                                    Text(
                                        "$creditsEarned/${requiredPoints ~/ 4}",
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: totalEarnedPoints / requiredPoints,
                              backgroundColor: Colors.grey.shade300,
                              color: purplePrimary,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                                "${requiredPoints - totalEarnedPoints} more CATS points needed to submit claim",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Note: Once submitted, your claim will be reviewed by the Co-Curriculum department. Approval may take 3-5 working days.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 80), // space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom fixed button: Submit Credit Claim
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ElevatedButton(
            onPressed: canSubmit ? submitClaim : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: purplePrimary,
              disabledBackgroundColor: Colors.grey.shade400,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Submit Credit Claim",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
