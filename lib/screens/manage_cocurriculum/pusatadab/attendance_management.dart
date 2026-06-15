// screens/manage_cocurriculum/attendance_management.dart
// Adab staff screen: search and view student co-curriculum attendance records.
// Theme: orange (AppColors.primary) header + white body.

import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../../models/manage_cocurriculum/attendance.dart';
import '../../../widgets/adab_sidebar.dart';
import '../../../utils/app_colors.dart';

// ---------- LIST SCREEN ----------
class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      AttendanceManagementScreenState();
}

class AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    service.seedSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StreamBuilder<int>(
        stream: service.getPendingClaimsCount(),
        builder: (context, snapshot) => AdabSidebar(
          activePage: 'attendance',
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
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Student Attendance Records",
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Co-Curriculum Attendance Management",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Search and view detailed attendance records for all co-curriculum activities",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Search by name or matric number
                    TextField(
                      onChanged: (value) =>
                          setState(() => searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search by name or matric number...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Export feature coming soon"),
                            ),
                          ),
                      icon: const Icon(Icons.download),
                      label: const Text("Export Attendance Report"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Live student attendance list
              Expanded(
                child: StreamBuilder<List<StudentAttendance>>(
                  stream: service.getAttendance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var students = snapshot.data!;
                    if (searchQuery.isNotEmpty) {
                      students = students
                          .where(
                            (s) =>
                                s.studentName.toLowerCase().contains(
                                  searchQuery,
                                ) ||
                                s.matricNumber.toLowerCase().contains(
                                  searchQuery,
                                ),
                          )
                          .toList();
                    }
                    if (students.isEmpty) {
                      return const Center(child: Text("No students found."));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, index) =>
                          buildStudentCard(students[index]),
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

  Widget buildStudentCard(StudentAttendance s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetailScreen(student: s),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.matricNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.programme,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      "${s.attendanceRate.toInt()}%",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      "Rate",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${s.totalAttended}/${s.totalRegistered} attended",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- DETAIL SCREEN ----------
class AttendanceDetailScreen extends StatelessWidget {
  final StudentAttendance student;
  const AttendanceDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance Details"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.studentName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.matricNumber,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student.programme,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${student.attendanceRate.toInt()}%",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          "Attendance",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    icon: Icons.event_available,
                    value: student.totalRegistered.toString(),
                    label: "Registered",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _infoCard(
                    icon: Icons.check_circle,
                    value: student.totalAttended.toString(),
                    label: "Attended",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Attendance Records",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: student.records.length,
              itemBuilder: (context, index) {
                final record = student.records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                record.moduleName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: record.isPresent
                                    ? AppColors.success.withAlpha(26)
                                    : AppColors.danger.withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                record.isPresent ? "Present" : "Absent",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: record.isPresent
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              record.date,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              record.checkInTime,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
