import 'package:flutter/material.dart';
import '../../../widgets/module_card.dart';
import '../../../widgets/std_sidebar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  static const Color purplePrimary = Color(0xFFAB43FE);
  static const Color purpleDark = Color(0xFF8B2FD9);

  final String studentName = 'Ahmad Imran bin Abdullah';
  final String matricNumber = 'CD210145';

  final List<Map<String, dynamic>> attendedActivities = const [
    {'name': 'Blood Donation Campaign', 'date': '5 Mar 2026', 'cats': 2, 'claimed': true},
    {'name': 'Coding Competition', 'date': '8 Mar 2026', 'cats': 2, 'claimed': true},
    {'name': 'Badminton Tournament', 'date': '10 Mar 2026', 'cats': 2, 'claimed': true},
    {'name': 'Cultural Night Festival', 'date': '12 Mar 2026', 'cats': 2, 'claimed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StudentSidebar(
        activePage: 'dashboard',
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
              // Purple header with hamburger menu
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
                          'Student Dashboard',
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

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Student Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [purplePrimary, purpleDark],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                      Text(
                                        studentName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        matricNumber,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'CGPA: 3.67',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bachelor of Computer Science (Software Engineering)',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Semester 2, 2025/2026',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fee Alert
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border(
                            left: BorderSide(
                                color: Colors.red.shade500, width: 4),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red.shade600),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Outstanding Fees',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Please settle your fees by Week 5 to avoid account blocking',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // How to Earn CATS Points Guide
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'How to Earn CATS Points',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildStep(Icons.event, 'Attend\nEvent',
                                    purplePrimary),
                                _buildArrow(),
                                _buildStep(Icons.smartphone, 'Submit\nCode',
                                    purpleDark),
                                _buildArrow(),
                                _buildStep(Icons.emoji_events, 'Claim\nCATS',
                                    Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⚡ No pre-registration! Just attend → Submit code → Claim CATS → 8 CATS = 2 Credits',
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // My Co-Curriculum Activities
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.emoji_events,
                                        color: purplePrimary, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'My Co-Curriculum Activities',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, '/student/modules'),
                                  child: const Text('View All',
                                      style:
                                          TextStyle(color: purplePrimary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...attendedActivities.take(3).map((activity) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['name'] as String,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                activity['date'] as String,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.emoji_events,
                                                  size: 12,
                                                  color: purplePrimary),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${activity['cats']} CATS',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: purplePrimary,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (activity['claimed'] as bool)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 12,
                                                color: Colors.green),
                                            SizedBox(width: 4),
                                            Text(
                                              'Claimed',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight:
                                                      FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pushReplacementNamed(
                                                context, '/student/claim'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: purplePrimary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                        ),
                                        child: const Text('Claim',
                                            style: TextStyle(fontSize: 12)),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.emoji_events,
                                          color: purplePrimary, size: 20),
                                      SizedBox(width: 4),
                                      Text('CATS Points',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '6/8',
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    '3 activities attended',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  const LinearProgressIndicator(
                                    value: 6 / 8,
                                    backgroundColor: Color(0xFFE5E7EB),
                                    color: purplePrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.book,
                                          color: Color(0xFF3B82F6), size: 20),
                                      SizedBox(width: 4),
                                      Text('Subjects',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '6',
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'Current semester',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 12, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text(
                                        'All registered',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Module Cards — Co-Curriculum
                      _buildModuleSection(
                        context,
                        'Co-Curriculum & Credits',
                        Icons.emoji_events,
                        purplePrimary,
                        [
                          ModuleCard(
                            title: 'Activities',
                            description: 'Browse co-curriculum activities',
                            icon: Icons.emoji_events,
                            color: purplePrimary,
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/student/modules'),
                          ),
                          ModuleCard(
                            title: 'Claim Hours',
                            description: 'Claim CATS points for activities',
                            icon: Icons.access_time,
                            color: purpleDark,
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/student/claim'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Module Cards — Attendance
                      _buildModuleSection(
                        context,
                        'Attendance',
                        Icons.location_on,
                        purplePrimary,
                        [
                          ModuleCard(
                            title: 'Check-In',
                            description: 'Mark attendance with code',
                            icon: Icons.location_on,
                            color: purplePrimary,
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/student/checkin'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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

  Widget _buildStep(IconData icon, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
    );
  }

  Widget _buildModuleSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
