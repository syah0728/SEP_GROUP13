import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/attendance_service.dart';
import 'services/firebase_seed_service.dart';
import 'theme/app_theme.dart';
import 'screens/actor_selection_view.dart';
import 'screens/lecturer_shell.dart';
import 'screens/student_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAttendanceService().seedIfNeeded();
  await FirebaseSeedService().seedIfNeeded();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAMS 2026',
      theme: AppTheme.light(),
      home: const MobilePreviewFrame(child: AppFlowRoot()),
    );
  }
}

class AppFlowRoot extends StatefulWidget {
  const AppFlowRoot({super.key});

  @override
  State<AppFlowRoot> createState() => _AppFlowRootState();
}

class _AppFlowRootState extends State<AppFlowRoot> {
  AppActor? selectedActor;

  void _selectActor(AppActor actor) {
    setState(() => selectedActor = actor);
  }

  void _switchActor() {
    setState(() => selectedActor = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (selectedActor) {
        null => ActorSelectionView(
          key: const ValueKey('actor-selection'),
          onSelectActor: _selectActor,
        ),
        AppActor.lecturer => LecturerShell(
          key: const ValueKey('lecturer'),
          lecturerId: 'LE210145',
          onSwitchActor: _switchActor,
        ),
        AppActor.student => StudentShell(
          key: const ValueKey('student'),
          studentId: 'A20CS1001',
          onSwitchActor: _switchActor,
        ),
      },
    );
  }
}

class MobilePreviewFrame extends StatelessWidget {
  const MobilePreviewFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 520) {
          return child;
        }

        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 844.0;
        final phoneHeight = min(844.0, max(0.0, availableHeight - 32));

        return ColoredBox(
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: Container(
              width: 390,
              height: phoneHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: Size(390, phoneHeight)),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
