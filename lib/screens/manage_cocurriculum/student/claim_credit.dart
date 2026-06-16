import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/std_sidebar.dart';
import '../../../services/firebase_services.dart';
import '../../../services/session_service.dart';

class ClaimCreditScreen extends StatefulWidget {
  const ClaimCreditScreen({super.key});

  @override
  State<ClaimCreditScreen> createState() => ClaimCreditScreenState();
}

class ClaimCreditScreenState extends State<ClaimCreditScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();

  String get studentName => AppSession.studentName;
  String get matricNumber => AppSession.matricId;

  static const Color purplePrimary = Color(0xFFAB43FE);
  static const int requiredPoints = 8;
  static const int pointsPerModule = 2;

  // All modules the student registered for [{moduleName, date}]
  List<Map<String, dynamic>> registeredModules = [];
  // Modules confirmed attended via check-in
  Set<String> attendedModuleNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final registered = await service.getRegisteredModuleRecords(matricNumber);
    final attended = await service.getAttendedModuleNames(matricNumber);
    if (!mounted) return;
    setState(() {
      registeredModules = registered;
      attendedModuleNames = attended;
      _loading = false;
    });
  }

  int get totalEarnedPoints => attendedModuleNames.length * pointsPerModule;
  bool get canSubmit => totalEarnedPoints >= requiredPoints;
  int get creditsEarned => totalEarnedPoints ~/ 4;

  Future<void> submitClaim() async {
    if (!canSubmit) return;

    // Prepare claim data for Firestore
    final claimData = {
      'studentName': studentName,
      'matricNumber': matricNumber,
      'submittedDate': DateTime.now().toLocal().toString().split(' ')[0],
      'status': 'pending',
      'modules': attendedModuleNames.toList(),
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
            content: Text(
              'Credit claim submitted successfully! Pending approval.',
            ),
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
            backgroundColor: Colors.red,
          ),
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
          context,
          '/login',
          (route) => false,
        ),
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
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Claim Credit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Main scrollable content
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CATS Points Progress Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: purplePrimary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.emoji_events,
                                          color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        "CATS Points Progress",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            "CATS Earned",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white70),
                                          ),
                                          Text(
                                            "$totalEarnedPoints/$requiredPoints",
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.white30,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Credits Earned",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white70),
                                          ),
                                          Text(
                                            "$creditsEarned/${requiredPoints ~/ 4}",
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: (totalEarnedPoints / requiredPoints)
                                        .clamp(0.0, 1.0),
                                    backgroundColor: Colors.white30,
                                    color: Colors.white,
                                    minHeight: 8,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    totalEarnedPoints >= requiredPoints
                                        ? "You have reached the required CATS points!"
                                        : "${requiredPoints - totalEarnedPoints} CATS points remaining for graduation eligibility",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Eligibility badge
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
                                      : const Color(0xFFFFCC80),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    canSubmit
                                        ? Icons.verified
                                        : Icons.info_outline,
                                    color: canSubmit
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          canSubmit
                                              ? 'Ready to Submit!'
                                              : 'Earn More Points',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: canSubmit
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
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
                            // Registered modules list
                            const Text(
                              "My Registered Modules",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Check in attendance to earn CATS points for each module.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (registeredModules.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    "No modules registered yet.\nGo to Co-Curriculum Modules to register.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: registeredModules.length,
                                itemBuilder: (context, index) {
                                  final module = registeredModules[index];
                                  final name = module['moduleName'] as String;
                                  final date = module['date'] as String;
                                  final isAttended =
                                      attendedModuleNames.contains(name);
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  date,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          if (isAttended)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.green.withAlpha(26),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "+$pointsPerModule pts",
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          else
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pushReplacementNamed(
                                                context,
                                                '/student/checkin',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "Check In",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 80,
                            ), // space for bottom button
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
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit Credit Claim",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
