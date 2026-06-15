// lib/models/attendance_model.dart
// This file defines the Student Attendance data.
// It tracks which students attended which co-curriculum modules.

class AttendanceRecord {
  final String moduleName; // e.g. "Kayak"
  final String date; // e.g. "25 March 2026"
  final String checkInTime; // e.g. "8:00 AM"
  final bool isPresent; // true = Present, false = Absent

  AttendanceRecord({
    required this.moduleName,
    required this.date,
    required this.checkInTime,
    required this.isPresent,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      moduleName: data['moduleName'] ?? '',
      date: data['date'] ?? '',
      checkInTime: data['checkInTime'] ?? '',
      isPresent: data['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moduleName': moduleName,
      'date': date,
      'checkInTime': checkInTime,
      'isPresent': isPresent,
    };
  }
}

class StudentAttendance {
  final String id; // Firestore document ID
  final String studentName; // e.g. "Ahmad Imran bin Abdullah"
  final String matricNumber; // e.g. "CD210145"
  final String programme; // e.g. "BCS (Software Engineering)"
  final int totalRegistered; // How many modules registered
  final int totalAttended; // How many modules actually attended
  final List<AttendanceRecord> records; // List of individual attendance records

  StudentAttendance({
    required this.id,
    required this.studentName,
    required this.matricNumber,
    required this.programme,
    required this.totalRegistered,
    required this.totalAttended,
    required this.records,
  });

  // Calculate attendance percentage
  double get attendanceRate {
    if (totalRegistered == 0) return 0;
    return (totalAttended / totalRegistered) * 100;
  }

  factory StudentAttendance.fromMap(String id, Map<String, dynamic> data) {
    // Convert the list of records from Firestore
    List<AttendanceRecord> records = [];
    if (data['records'] != null) {
      for (var record in data['records']) {
        records.add(AttendanceRecord.fromMap(record));
      }
    }

    return StudentAttendance(
      id: id,
      studentName: data['studentName'] ?? '',
      matricNumber: data['matricNumber'] ?? '',
      programme: data['programme'] ?? '',
      totalRegistered: data['totalRegistered'] ?? 0,
      totalAttended: data['totalAttended'] ?? 0,
      records: records,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'matricNumber': matricNumber,
      'programme': programme,
      'totalRegistered': totalRegistered,
      'totalAttended': totalAttended,
      'records': records.map((r) => r.toMap()).toList(),
    };
  }
}
