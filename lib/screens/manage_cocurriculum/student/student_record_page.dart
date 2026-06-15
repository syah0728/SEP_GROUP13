import 'package:flutter/material.dart';
import '../../../controllers/manage_attendance/student_attendance_controller.dart';
import '../../manage_attendance/student/view_attendance.dart';

/// Adapter that wires the Module-3 attendance record flow into the
/// Module-2 student route (/student/record). Back-navigation on the
/// subject list returns to /student/dashboard.
class StudentRecordPage extends StatefulWidget {
  const StudentRecordPage({super.key});

  @override
  State<StudentRecordPage> createState() => _StudentRecordPageState();
}

class _StudentRecordPageState extends State<StudentRecordPage> {
  late final StudentAttendanceController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = StudentAttendanceController(studentId: 'A20CS1001');
    _controller.addListener(_onControllerChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _controller.initialize();
    await _controller.openAttendanceRecord();
    _initialized = true;
  }

  void _onControllerChanged() {
    if (!mounted || !_initialized) return;
    if (_controller.activeScreen == StudentScreen.dashboard) {
      Navigator.pushReplacementNamed(context, '/student/dashboard');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.activeScreen == StudentScreen.courseAttendance) {
          return StudentCourseAttendanceView(controller: _controller);
        }
        return StudentAttendanceRecordView(controller: _controller);
      },
    );
  }
}
