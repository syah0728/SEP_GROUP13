import 'package:flutter/material.dart';

import '../controllers/manage_attendance/attendance_controller.dart';
import 'manage_attendance/lecturer/attendance_management.dart';
import 'manage_attendance/lecturer/attendance_record.dart';

class LecturerShell extends StatefulWidget {
  const LecturerShell({
    super.key,
    required this.lecturerId,
    this.onSwitchActor,
  });

  final String lecturerId;
  final VoidCallback? onSwitchActor;

  @override
  State<LecturerShell> createState() => _LecturerShellState();
}

class _LecturerShellState extends State<LecturerShell> {
  late final AttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = AttendanceController(lecturerId: widget.lecturerId)
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
    return Scaffold(
      drawer: LecturerDrawer(
        selectedIndex: controller.selectedMenuIndex,
        onSwitchActor: widget.onSwitchActor,
        onSelect: (index) {
          controller.selectMenu(index);
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage != null && controller.lecturer == null) {
      return ErrorView(
        message: controller.errorMessage!,
        onRetry: controller.initialize,
      );
    }
    return _activeView();
  }

  Widget _activeView() {
    return switch (controller.activeScreen) {
      AttendanceScreen.dashboard => AttendanceDashboardView(
        controller: controller,
      ),
      AttendanceScreen.classes => AttendanceClassesView(controller: controller),
      AttendanceScreen.classDetails => AttendanceClassDetailsView(
        controller: controller,
      ),
      AttendanceScreen.generateCode => AttendanceGenerateCodeView(
        controller: controller,
      ),
      AttendanceScreen.generatedQr => AttendanceGeneratedQrView(
        controller: controller,
      ),
      AttendanceScreen.attendanceRecordSelection =>
        AttendanceRecordSelectionView(controller: controller),
      AttendanceScreen.attendanceRecordList => AttendanceRecordListView(
        controller: controller,
      ),
    };
  }
}
