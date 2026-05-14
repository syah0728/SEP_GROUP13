import 'enums.dart';

export 'enums.dart';

class LecturerProfile {
  const LecturerProfile({
    required this.name,
    required this.lecturerId,
    required this.title,
    required this.semesterLabel,
  });

  final String name;
  final String lecturerId;
  final String title;
  final String semesterLabel;
}

class Course {
  const Course({
    required this.courseName,
    required this.courseCode,
    required this.curriculum,
    required this.semesterLabel,
    required this.enrolledCount,
    required this.lecturerId,
    required this.lecturerName,
    required this.schedules,
  });

  final String courseName;
  final String courseCode;
  final String curriculum;
  final String semesterLabel;
  final int enrolledCount;
  final String lecturerId;
  final String lecturerName;
  final List<SessionOption> schedules;
}

class SessionOption {
  const SessionOption({
    required this.scheduleId,
    required this.section,
    required this.date,
    required this.timeLabel,
    required this.location,
  });

  final String scheduleId;
  final String section;
  final String date;
  final String timeLabel;
  final CampusLocation location;
}

class CampusLocation {
  const CampusLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}

class AttendanceSession {
  const AttendanceSession({
    required this.sessionId,
    required this.course,
    required this.session,
    required this.code,
    required this.generatedAt,
    required this.qrSeed,
  });

  final String sessionId;
  final Course course;
  final SessionOption session;
  final String code;
  final DateTime generatedAt;
  final String qrSeed;
}

class GpsValidationResult {
  const GpsValidationResult({required this.isAllowed, required this.message});

  final bool isAllowed;
  final String message;
}

class StudentAttendanceRecord {
  const StudentAttendanceRecord({
    required this.recordId,
    required this.matricId,
    required this.name,
    required this.studentId,
    required this.status,
  });

  final String recordId;
  final String matricId;
  final String name;
  final String studentId;
  final AttendanceStatus status;

  StudentAttendanceRecord copyWith({AttendanceStatus? status}) {
    return StudentAttendanceRecord(
      recordId: recordId,
      matricId: matricId,
      name: name,
      studentId: studentId,
      status: status ?? this.status,
    );
  }
}
