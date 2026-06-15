// screens/manage_cocurriculum/adab_dashboard.dart
// Main landing page for Pusat Adab staff after login.
// Shows activity stats, pending claims alert, and upcoming modules.
// Theme: orange (#FF6900) header + white body.

import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../../widgets/adab_sidebar.dart';
import '../../../models/manage_cocurriculum/module.dart';

class AdabDashboard extends StatefulWidget {
  const AdabDashboard({super.key});

  @override
  State<AdabDashboard> createState() => AdabDashboardState();
}

class AdabDashboardState extends State<AdabDashboard> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();
  late Future<Map<String, int>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = service.getDashboardStats();
    service.seedSampleData(); // insert demo data if Firestore is empty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // Side navigation drawer
      drawer: StreamBuilder<int>(
        stream: service.getPendingClaimsCount(),
        builder: (context, snapshot) => AdabSidebar(
          activePage: 'dashboard',
          pendingClaimsCount: snapshot.data ?? 0,
          onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Orange header bar
              Container(
                color: const Color(0xFFFF6900),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                          "Pusat Adab Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
              // Scrollable dashboard body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row: Activities / Approved / Pending
                      FutureBuilder<Map<String, int>>(
                        future: statsFuture,
                        builder: (context, snapshot) {
                          final stats =
                              snapshot.data ??
                              {'activities': 0, 'approved': 0, 'pending': 0};
                          return Row(
                            children: [
                              statCard(
                                "Activities",
                                stats['activities']!,
                                Icons.event,
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              statCard(
                                "Approved",
                                stats['approved']!,
                                Icons.check_circle,
                                Colors.green,
                              ),
                              const SizedBox(width: 12),
                              statCard(
                                "Pending",
                                stats['pending']!,
                                Icons.pending,
                                Colors.orange,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Live pending claims alert
                      StreamBuilder<int>(
                        stream: service.getPendingClaimsCount(),
                        builder: (context, snapshot) {
                          final pending = snapshot.data ?? 0;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEFCE8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  color: Color(0xFF733E0A),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Pending Claims",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF733E0A),
                                        ),
                                      ),
                                      Text(
                                        "$pending student claim${pending != 1 ? 's are' : ' is'} waiting for validation",
                                        style: const TextStyle(
                                          color: Color(0xFFA65F00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Quick-link card to Validate Claims screen
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/claims'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF0B100)),
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Validate Claims",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Badge shows pending count
                                        StreamBuilder<int>(
                                          stream: service
                                              .getPendingClaimsCount(),
                                          builder: (context, snapshot) {
                                            final pending = snapshot.data ?? 0;
                                            if (pending == 0) {
                                              return const SizedBox();
                                            }
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFB2C36),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "$pending",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Review and approve student hour claims",
                                      style: TextStyle(
                                        color: Color(0xFF4A5565),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Upcoming module",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Live list of upcoming modules (up to 3)
                      StreamBuilder<List<ModuleModel>>(
                        stream: service.getModules(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final modules = snapshot.data!;
                          if (modules.isEmpty) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("No modules scheduled"),
                              ),
                            );
                          }
                          return Column(
                            children: modules.take(3).map((m) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    m.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${m.date} | ${m.registeredCount}/${m.maxParticipants} registered",
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/modules'),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4A5565)),
            ),
          ],
        ),
      ),
    );
  }
}
