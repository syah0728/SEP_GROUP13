import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/manage_attendance/student_models.dart';

// ── Firestore Mappers (Firebase logic isolated here, not in models) ────────────

StudentProfile _studentFromDoc(Map<String, dynamic> d) => StudentProfile(
  name: d['name'] ?? '',
  studentId: d['studentId'] ?? '',
  matricId: d['matricId'] ?? '',
  program: d['program'] ?? '',
);

StudentClassDetails _classDetailsFromDoc(String id, Map<String, dynamic> d) =>
    StudentClassDetails(
      sessionId: id,
      className: d['courseName'] ?? '',
      classCode: d['courseCode'] ?? '',
      section: d['section'] ?? '',
      date: d['date'] ?? '',
      time: d['timeLabel'] ?? '',
      sessionStatus: 'Session Active',
      attendanceCode: d['code'] ?? '',
      latitude: (d['latitude'] ?? 0.0).toDouble(),
      longitude: (d['longitude'] ?? 0.0).toDouble(),
    );

EnrolledCourse _enrolledCourseFromDoc(Map<String, dynamic> d) => EnrolledCourse(
  courseCode: d['courseCode'] ?? '',
  courseName: d['courseName'] ?? '',
  lecturerName: d['lecturerName'] ?? '',
  curriculum: d['curriculum'] ?? '',
);

AttendanceHistoryEntry _historyFromDoc(Map<String, dynamic> d) =>
    AttendanceHistoryEntry(
      date: d['date'] ?? '',
      timeLabel: d['timeLabel'] ?? '',
      section: d['section'] ?? '',
      isPresent: d['status'] == 'present',
      submittedAt: (d['submittedAt'] as Timestamp?)?.toDate(),
    );

// ── Custom Exception ──────────────────────────────────────────────────────────

class AlreadySubmittedException implements Exception {
  const AlreadySubmittedException();
}

// ── Abstract Interface ────────────────────────────────────────────────────────

abstract class StudentAttendanceService {
  Future<StudentProfile?> fetchStudentProfile(String studentId);
  Future<StudentClassDetails?> verifyAttendanceCode(String code);
  Future<StudentAttendanceSubmission> submitAttendance({
    required String studentId,
    required String matricId,
    required String studentName,
    required StudentClassDetails classDetails,
  });
  Future<List<EnrolledCourse>> fetchEnrolledCourses(String studentId);
  Future<CourseAttendanceSummary> fetchCourseAttendance({
    required String studentId,
    required EnrolledCourse course,
  });
}

// ── Firebase Implementation ───────────────────────────────────────────────────

class FirebaseStudentAttendanceService implements StudentAttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<StudentProfile?> fetchStudentProfile(String studentId) async {
    final doc = await _db.collection('students').doc(studentId).get();
    if (!doc.exists) return null;
    return _studentFromDoc(doc.data()!);
  }

  @override
  Future<StudentClassDetails?> verifyAttendanceCode(String code) async {
    if (code.trim().isEmpty) return null;
    final snap = await _db
        .collection('attendanceSessions')
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return _classDetailsFromDoc(doc.id, doc.data());
  }

  @override
  Future<StudentAttendanceSubmission> submitAttendance({
    required String studentId,
    required String matricId,
    required String studentName,
    required StudentClassDetails classDetails,
  }) async {
    final recordId = '${classDetails.sessionId}_$studentId';

    // Rule: Students can submit attendance only once per session [SRS Rule 3]
    final existing = await _db
        .collection('attendanceRecords')
        .doc(recordId)
        .get();
    if (existing.exists && existing.data()?['status'] == 'present') {
      throw const AlreadySubmittedException();
    }

    final now = DateTime.now();

    await _db.collection('attendanceRecords').doc(recordId).set({
      'sessionId': classDetails.sessionId,
      'courseCode': classDetails.classCode,
      'courseName': classDetails.className,
      'section': classDetails.section,
      'date': classDetails.date,
      'timeLabel': classDetails.time,
      'studentId': studentId,
      'matricId': matricId,
      'studentName': studentName,
      'status': 'present',
      'submittedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return StudentAttendanceSubmission(
      studentId: studentId,
      attendanceCode: classDetails.attendanceCode,
      submittedAt: now,
    );
  }

  @override
  Future<List<EnrolledCourse>> fetchEnrolledCourses(String studentId) async {
    final snap = await _db
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .get();
    return snap.docs.map((d) => _enrolledCourseFromDoc(d.data())).toList();
  }

  @override
  Future<CourseAttendanceSummary> fetchCourseAttendance({
    required String studentId,
    required EnrolledCourse course,
  }) async {
    final snap = await _db
        .collection('attendanceRecords')
        .where('studentId', isEqualTo: studentId)
        .where('courseCode', isEqualTo: course.courseCode)
        .get();

    final history = snap.docs.map((d) => _historyFromDoc(d.data())).toList();

    history.sort((a, b) => b.date.compareTo(a.date));

    final totalPresent = history.where((h) => h.isPresent).length;
    final totalAbsent = history.where((h) => !h.isPresent).length;

    return CourseAttendanceSummary(
      course: course,
      totalPresent: totalPresent,
      totalAbsent: totalAbsent,
      history: history,
    );
  }
}
