import 'package:flutter/material.dart';
import '../../../controllers/manage_attendance/student_attendance_controller.dart';
import '../../../widgets/std_sidebar.dart';
import '../../manage_attendance/student/submit_attendance.dart';

class StudentCheckinPage extends StatefulWidget {
  const StudentCheckinPage({super.key});

  @override
  State<StudentCheckinPage> createState() => _StudentCheckinPageState();
}

class _StudentCheckinPageState extends State<StudentCheckinPage> {
  late final StudentAttendanceController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // Prevent the listener from navigating during the bootstrap phase
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
    _controller.openSubmitAttendance();
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

  Widget _sidebar() => StudentSidebar(
        activePage: 'checkin',
        studentName: 'Ahmad Imran',
        matricNumber: 'CD210145',
        onLogout: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.activeScreen == StudentScreen.classDetails) {
          return StudentClassDetailsView(controller: _controller);
        }
        return StudentSubmitView(
          controller: _controller,
          scaffoldKey: _scaffoldKey,
          drawer: _sidebar(),
        );
      },
    );
  }
}
