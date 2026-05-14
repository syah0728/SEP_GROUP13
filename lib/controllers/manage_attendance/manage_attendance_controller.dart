import '../../models/manage_attendance/manage_attendance_model.dart';

class ManageAttendanceController {
  const ManageAttendanceController();

  ManageAttendanceModel buildModule() {
    return const ManageAttendanceModel(
      moduleId: 'manage_attendance',
      moduleTitle: 'Manage Attendance',
      moduleDescription:
          'Attendance module for lecturer check-in, student submission, and record review.',
      features: <String>[
        'Lecturer dashboard and attendance code generation',
        'Student attendance submission via QR or manual code',
        'Attendance record tracking and updates',
      ],
    );
  }
}
