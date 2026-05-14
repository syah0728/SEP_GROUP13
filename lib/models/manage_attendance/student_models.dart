import 'enums.dart';

export 'enums.dart';

class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.studentId,
    required this.matricId,
    required this.program,
  });

  final String name;
  final String studentId;
  final String matricId;
  final String program;
}

class EnrolledCourse {
  const EnrolledCourse({
    required this.courseCode,
    required this.courseName,
    required this.lecturerName,
    required this.curriculum,
  });

  final String courseCode;
  final String courseName;
  final String lecturerName;
  final String curriculum;
}

class StudentClassDetails {
  const StudentClassDetails({
    required this.sessionId,
    required this.className,
    required this.classCode,
    required this.section,
    required this.date,
    required this.time,
    required this.sessionStatus,
    required this.attendanceCode,
    required this.latitude,
    required this.longitude,
  });

  final String sessionId;
  final String className;
  final String classCode;
  final String section;
  final String date;
  final String time;
  final String sessionStatus;
  final String attendanceCode;
  final double latitude;
  final double longitude;
}

class StudentAttendanceSubmission {
  const StudentAttendanceSubmission({
    required this.studentId,
    required this.attendanceCode,
    required this.submittedAt,
  });

  final String studentId;
  final String attendanceCode;
  final DateTime submittedAt;
}

class StudentLocationResult {
  const StudentLocationResult({required this.isAllowed, required this.message});

  final bool isAllowed;
  final String message;
}

class AttendanceHistoryEntry {
  const AttendanceHistoryEntry({
    required this.date,
    required this.timeLabel,
    required this.section,
    required this.isPresent,
    this.submittedAt,
  });

  final String date;
  final String timeLabel;
  final String section;
  final bool isPresent;
  final DateTime? submittedAt;
}

class CourseAttendanceSummary {
  const CourseAttendanceSummary({
    required this.course,
    required this.totalPresent,
    required this.totalAbsent,
    required this.history,
  });

  final EnrolledCourse course;
  final int totalPresent;
  final int totalAbsent;
  final List<AttendanceHistoryEntry> history;

  int get totalSessions => totalPresent + totalAbsent;

  double get attendanceRate =>
      totalSessions == 0 ? 0 : totalPresent / totalSessions * 100;

  AttendanceBadge get badge {
    if (attendanceRate >= 80) return AttendanceBadge.good;
    if (attendanceRate >= 60) return AttendanceBadge.fair;
    return AttendanceBadge.poor;
  }
}
