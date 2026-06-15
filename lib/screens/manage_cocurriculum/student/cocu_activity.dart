import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../../models/manage_cocurriculum/module.dart';
import '../../../widgets/std_sidebar.dart';

class CoCurriculumModulesScreen extends StatefulWidget {
  const CoCurriculumModulesScreen({super.key});

  @override
  State<CoCurriculumModulesScreen> createState() =>
      CoCurriculumModulesScreenState();
}

class CoCurriculumModulesScreenState extends State<CoCurriculumModulesScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();
  final String studentName = "Ahmad Imran";
  final String matricNumber = "CD210145";

  // Studentâ€™s registered & attended modules (demo data)
  final Set<String> registeredModuleIds = {"Kayak", "3D Printing"};
  final Set<String> attendedModuleIds = {"Kayak", "3D Printing", "Memanah"};

  // Purple color
  static const Color purplePrimary = Color(0xFFAB43FE);
  static const Color purpleLight = Color(0xFFF3E8FF);

  @override
  void initState() {
    super.initState();
    service.seedSampleData();
  }

  void registerModule(ModuleModel module) {
    setState(() {
      registeredModuleIds.add(module.title);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered for ${module.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StudentSidebar(
        activePage: 'modules',
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
                        const Text(
                          "Co-Curriculum Modules",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
              // Eligible badge (green)
              Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Credit Claim Eligible âœ“",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                              "You have joined 4+ activities and can now claim credits!",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Stats row (purple icons)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    statCard("Joined", registeredModuleIds.length.toString(),
                        Icons.people),
                    const SizedBox(width: 16),
                    statCard("Attended", attendedModuleIds.length.toString(),
                        Icons.event_available),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search activities...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Modules list
              Expanded(
                child: StreamBuilder<List<ModuleModel>>(
                  stream: service.getModules(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final modules = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final m = modules[index];
                        final isRegistered =
                            registeredModuleIds.contains(m.title);
                        final isAttended = attendedModuleIds.contains(m.title);
                        String statusText = isAttended
                            ? "Attended"
                            : (isRegistered ? "Registered" : "Available");
                        Color statusColor = isAttended
                            ? Colors.green
                            : (isRegistered ? Colors.orange : purplePrimary);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(m.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(26),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(statusText,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 4),
                                  Text(m.date)
                                ]),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 4),
                                  Text(m.venue)
                                ]),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 4),
                                  Text("${m.startTime} - ${m.endTime}")
                                ]),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.people, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                      "${m.registeredCount}/${m.maxParticipants} participants")
                                ]),
                                const SizedBox(height: 12),
                                if (!isRegistered && !isAttended)
                                  ElevatedButton(
                                    onPressed: () => registerModule(m),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: purplePrimary),
                                    child: const Text("Register"),
                                  ),
                                if (isRegistered && !isAttended)
                                  const Text("Attendance not yet recorded",
                                      style: TextStyle(color: Colors.orange)),
                                if (isAttended)
                                  const Text("Completed",
                                      style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: purplePrimary),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
