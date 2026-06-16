import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/manage_attendance/student_models.dart';

// ── Firestore Mappers ─────────────────────────────────────────────────────────

StudentProfile _studentFromDoc(Map<String, dynamic> d) => StudentProfile(
  name: d['studentName'] ?? d['name'] ?? '',
  studentId: d['studentID'] ?? d['studentId'] ?? '',
  matricId: d['matricId'] ?? d['matricID'] ?? d['studentID'] ?? '',
  program: d['programme'] ?? d['program'] ?? '',
);

StudentClassDetails _classDetailsFromDoc(String id, Map<String, dynamic> d) =>
    StudentClassDetails(
      sessionId: id,
      className: d['course_name'] ?? d['courseName'] ?? '',
      classCode: d['courseID'] ?? d['courseCode'] ?? '',
      section: d['section'] ?? '',
      date: d['date'] ?? '',
      time: d['timeLabel'] ?? '',
      sessionStatus: 'Session Active',
      attendanceCode: d['code'] ?? '',
      latitude: (d['latitude'] ?? 0.0).toDouble(),
      longitude: (d['longitude'] ?? 0.0).toDouble(),
    );

EnrolledCourse _enrolledCourseFromDoc(Map<String, dynamic> d) => EnrolledCourse(
  courseCode: d['course_id'] ?? d['courseCode'] ?? '',
  courseName: d['course_name'] ?? d['courseName'] ?? '',
  lecturerName: d['lecturer_name'] ?? d['lecturerName'] ?? '',
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
    final cleanCode = code.trim().toUpperCase();

    // Try short 'code' field first (manual entry)
    var snap = await _db
        .collection('attendanceSessions')
        .where('code', isEqualTo: cleanCode)
        .limit(1)
        .get();

    // Fall back to 'qrSeed' field (QR scan returns the full seed value)
    if (snap.docs.isEmpty) {
      snap = await _db
          .collection('attendanceSessions')
          .where('qrSeed', isEqualTo: code.trim())
          .limit(1)
          .get();
    }

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

    // Rule: Students can submit attendance only once per session
    final existing =
        await _db.collection('attendanceRecords').doc(recordId).get();
    if (existing.exists && existing.data()?['status'] == 'present') {
      throw const AlreadySubmittedException();
    }

    final now = DateTime.now();

    await _db.collection('attendanceRecords').doc(recordId).set({
      'sessionID': classDetails.sessionId,
      'courseID': classDetails.classCode,
      'courseName': classDetails.className,
      'section': classDetails.section,
      'date': classDetails.date,
      'timeLabel': classDetails.time,
      'studentID': studentId,
      'matricID': matricId,
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
    // Try ERD field name first, fallback to old field name
    var snap = await _db
        .collection('enrollments')
        .where('studentID', isEqualTo: studentId)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _db
          .collection('enrollments')
          .where('studentId', isEqualTo: studentId)
          .get();
    }

    return snap.docs.map((d) => _enrolledCourseFromDoc(d.data())).toList();
  }

  @override
  Future<CourseAttendanceSummary> fetchCourseAttendance({
    required String studentId,
    required EnrolledCourse course,
  }) async {
    // Try ERD field names first, fallback to old field names
    var snap = await _db
        .collection('attendanceRecords')
        .where('studentID', isEqualTo: studentId)
        .where('courseID', isEqualTo: course.courseCode)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _db
          .collection('attendanceRecords')
          .where('studentId', isEqualTo: studentId)
          .where('courseCode', isEqualTo: course.courseCode)
          .get();
    }

    final history =
        snap.docs.map((d) => _historyFromDoc(d.data())).toList();

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
