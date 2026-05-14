import 'package:flutter/material.dart';

import '../controllers/manage_attendance/student_attendance_controller.dart';
import 'manage_attendance/student/submit_attendance.dart';
import 'manage_attendance/student/view_attendance.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key, required this.studentId, this.onSwitchActor});

  final String studentId;
  final VoidCallback? onSwitchActor;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late final StudentAttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = StudentAttendanceController(studentId: widget.studentId)
      ..addListener(_refresh);
    controller.initialize();
  }

  @override
  void dispose() {
    controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.errorMessage != null && controller.student == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.initialize,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return switch (controller.activeScreen) {
      StudentScreen.dashboard => StudentDashboardView(
        controller: controller,
        onSwitchActor: widget.onSwitchActor,
      ),
      StudentScreen.submitAttendance => StudentSubmitView(
        controller: controller,
      ),
      StudentScreen.classDetails => StudentClassDetailsView(
        controller: controller,
      ),
      StudentScreen.attendanceRecord => StudentAttendanceRecordView(
        controller: controller,
      ),
      StudentScreen.courseAttendance => StudentCourseAttendanceView(
        controller: controller,
      ),
    };
  }
}
