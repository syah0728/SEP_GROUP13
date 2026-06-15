import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/manage_attendance/attendance_models.dart';

// ── Firestore Mappers ─────────────────────────────────────────────────────────

LecturerProfile _lecturerFromDoc(Map<String, dynamic> d) => LecturerProfile(
  name: d['lecturer_name'] ?? d['name'] ?? '',
  lecturerId: d['lecturerID'] ?? d['lecturerId'] ?? '',
  title: d['department'] ?? d['title'] ?? '',
  semesterLabel: d['semesterLabel'] ?? 'Semester 2, 2025/2026',
);

SessionOption _sessionFromDoc(String id, Map<String, dynamic> d) =>
    SessionOption(
      scheduleId: id,
      section: d['section'] ?? '',
      date: d['date'] ?? '',
      timeLabel: d['timeLabel'] ?? '',
      location: CampusLocation(
        name: d['locationName'] ?? '',
        latitude: (d['latitude'] ?? 0.0).toDouble(),
        longitude: (d['longitude'] ?? 0.0).toDouble(),
      ),
    );

Course _courseFromDoc(Map<String, dynamic> d, List<SessionOption> schedules) =>
    Course(
      courseName: d['course_name'] ?? d['courseName'] ?? '',
      courseCode: d['course_id'] ?? d['courseCode'] ?? '',
      curriculum: d['curriculum'] ?? '',
      semesterLabel: d['semesterLabel'] ?? 'Semester 2, 2025/2026',
      enrolledCount: (d['enrolledCount'] ?? 0) as int,
      lecturerId: d['lecturerID'] ?? d['lecturerId'] ?? '',
      lecturerName: d['lecturer_name'] ?? d['lecturerName'] ?? '',
      schedules: schedules,
    );

StudentAttendanceRecord _recordFromDoc(String id, Map<String, dynamic> d) =>
    StudentAttendanceRecord(
      recordId: id,
      matricId: d['matricID'] ?? d['matricId'] ?? '',
      name: d['studentName'] ?? '',
      studentId: d['studentID'] ?? d['studentId'] ?? '',
      status: d['status'] == 'present'
          ? AttendanceStatus.present
          : AttendanceStatus.absent,
    );

// ── Abstract Interface ────────────────────────────────────────────────────────

abstract class AttendanceService {
  Future<LecturerProfile?> fetchLecturerProfile(String lecturerId);
  Future<List<Course>> fetchAssignedCourses(String lecturerId);
  Future<AttendanceSession> createAttendanceSession({
    required Course course,
    required SessionOption session,
    required String lecturerId,
  });
  Future<List<StudentAttendanceRecord>> fetchAttendanceRecords({
    required Course course,
    required SessionOption session,
  });
  Future<void> updateAttendanceRecord({
    required String recordId,
    required AttendanceStatus status,
  });
}

// ── Firebase Implementation ───────────────────────────────────────────────────

class FirebaseAttendanceService implements AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _codeGen = _AttendanceCodeGenerator();

  @override
  Future<LecturerProfile?> fetchLecturerProfile(String lecturerId) async {
    await seedIfNeeded();
    final doc = await _db.collection('lecturers').doc(lecturerId).get();
    if (!doc.exists) return null;
    return _lecturerFromDoc(doc.data()!);
  }

  @override
  Future<List<Course>> fetchAssignedCourses(String lecturerId) async {
    // Try ERD field name first, fallback to old field name
    var snap = await _db
        .collection('courses')
        .where('lecturerID', isEqualTo: lecturerId)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _db
          .collection('courses')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();
    }

    final courses = <Course>[];
    for (final doc in snap.docs) {
      final schedules = await _fetchSchedules(doc.id);
      courses.add(_courseFromDoc(doc.data(), schedules));
    }
    return courses;
  }

  Future<List<SessionOption>> _fetchSchedules(String courseCode) async {
    // schedules collection uses courseCode (implementation detail, not in ERD)
    var snap = await _db
        .collection('schedules')
        .where('courseCode', isEqualTo: courseCode)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _db
          .collection('schedules')
          .where('courseID', isEqualTo: courseCode)
          .get();
    }

    return snap.docs.map((d) => _sessionFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<AttendanceSession> createAttendanceSession({
    required Course course,
    required SessionOption session,
    required String lecturerId,
  }) async {
    final code = await _generateUniqueCode();
    final qrSeed =
        '${course.courseCode}-${session.section}-${session.date}-$code';

    final sessionData = {
      'courseID': course.courseCode,
      'courseName': course.courseName,
      'scheduleId': session.scheduleId,
      'section': session.section,
      'date': session.date,
      'timeLabel': session.timeLabel,
      'code': code,
      'qrSeed': qrSeed,
      'generatedAt': FieldValue.serverTimestamp(),
      'lecturerID': lecturerId,
      'locationName': session.location.name,
      'latitude': session.location.latitude,
      'longitude': session.location.longitude,
    };

    // Reuse the existing session doc for this course/section/date/time (if
    // one was generated before) instead of creating a duplicate, so
    // attendanceRecords stay tied to a single sessionId across regenerates.
    final sessionId = await _findOrCreateSessionId(
      course: course,
      session: session,
      sessionData: sessionData,
    );

    await _createAbsentRecordsForSession(
      sessionId: sessionId,
      course: course,
      session: session,
    );

    return AttendanceSession(
      sessionId: sessionId,
      course: course,
      session: session,
      code: code,
      generatedAt: DateTime.now(),
      qrSeed: qrSeed,
    );
  }

  Future<String> _findOrCreateSessionId({
    required Course course,
    required SessionOption session,
    required Map<String, dynamic> sessionData,
  }) async {
    // Try ERD field name first, fallback to old field name
    var snap = await _db
        .collection('attendanceSessions')
        .where('courseID', isEqualTo: course.courseCode)
        .where('section', isEqualTo: session.section)
        .where('date', isEqualTo: session.date)
        .where('timeLabel', isEqualTo: session.timeLabel)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _db
          .collection('attendanceSessions')
          .where('courseCode', isEqualTo: course.courseCode)
          .where('section', isEqualTo: session.section)
          .where('date', isEqualTo: session.date)
          .where('timeLabel', isEqualTo: session.timeLabel)
          .limit(1)
          .get();
    }

    if (snap.docs.isNotEmpty) {
      final id = snap.docs.first.id;
      await _db
          .collection('attendanceSessions')
          .doc(id)
          .set(sessionData, SetOptions(merge: true));
      return id;
    }

    final ref = await _db.collection('attendanceSessions').add(sessionData);
    return ref.id;
  }

  Future<void> _createAbsentRecordsForSession({
    required String sessionId,
    required Course course,
    required SessionOption session,
  }) async {
    // Try ERD field name first, fallback to old field name
    QuerySnapshot enrollSnap = await _db
        .collection('enrollments')
        .where('course_id', isEqualTo: course.courseCode)
        .get();

    if (enrollSnap.docs.isEmpty) {
      enrollSnap = await _db
          .collection('enrollments')
          .where('courseCode', isEqualTo: course.courseCode)
          .get();
    }

    // Skip students who already have a record for this session (e.g. when
    // the lecturer regenerates the code) so their existing status isn't
    // reset back to absent.
    final existingSnap = await _db
        .collection('attendanceRecords')
        .where('sessionID', isEqualTo: sessionId)
        .get();
    final existingIds = existingSnap.docs.map((d) => d.id).toSet();

    final batch = _db.batch();
    for (final enroll in enrollSnap.docs) {
      final data = enroll.data() as Map<String, dynamic>;
      final studentId = data['studentID'] ?? data['studentId'] ?? '';

      final recordId = '${sessionId}_$studentId';
      if (existingIds.contains(recordId)) continue;

      // Get name and matricId from enrollment, fallback to students collection
      String studentName = data['studentName'] ?? '';
      String matricId = data['matricID'] ?? data['matricId'] ?? '';

      if (studentName.isEmpty || matricId.isEmpty) {
        final studentDoc =
            await _db.collection('students').doc(studentId).get();
        if (studentDoc.exists) {
          final sd = studentDoc.data()!;
          studentName =
              sd['studentName'] ?? sd['name'] ?? studentName;
          matricId = sd['matricId'] ?? sd['matricID'] ?? matricId;
        }
      }

      final ref = _db.collection('attendanceRecords').doc(recordId);
      batch.set(ref, {
        'sessionID': sessionId,
        'courseID': course.courseCode,
        'courseName': course.courseName,
        'section': session.section,
        'date': session.date,
        'timeLabel': session.timeLabel,
        'studentID': studentId,
        'matricID': matricId,
        'studentName': studentName,
        'status': 'absent',
        'submittedAt': null,
      });
    }
    await batch.commit();
  }

  @override
  Future<List<StudentAttendanceRecord>> fetchAttendanceRecords({
    required Course course,
    required SessionOption session,
  }) async {
    // Try ERD field name first, fallback to old field name
    var sessionSnap = await _db
        .collection('attendanceSessions')
        .where('courseID', isEqualTo: course.courseCode)
        .where('section', isEqualTo: session.section)
        .where('date', isEqualTo: session.date)
        .where('timeLabel', isEqualTo: session.timeLabel)
        .limit(1)
        .get();

    if (sessionSnap.docs.isEmpty) {
      sessionSnap = await _db
          .collection('attendanceSessions')
          .where('courseCode', isEqualTo: course.courseCode)
          .where('section', isEqualTo: session.section)
          .where('date', isEqualTo: session.date)
          .where('timeLabel', isEqualTo: session.timeLabel)
          .limit(1)
          .get();
    }

    if (sessionSnap.docs.isEmpty) return [];

    final sessionId = sessionSnap.docs.first.id;

    // Try ERD field name first, fallback to old field name
    var recordsSnap = await _db
        .collection('attendanceRecords')
        .where('sessionID', isEqualTo: sessionId)
        .get();

    if (recordsSnap.docs.isEmpty) {
      recordsSnap = await _db
          .collection('attendanceRecords')
          .where('sessionId', isEqualTo: sessionId)
          .get();
    }

    final records = recordsSnap.docs
        .map((d) => _recordFromDoc(d.id, d.data()))
        .toList();
    records.sort((a, b) => a.name.compareTo(b.name));
    return records;
  }

  @override
  Future<void> updateAttendanceRecord({
    required String recordId,
    required AttendanceStatus status,
  }) async {
    await _db.collection('attendanceRecords').doc(recordId).update({
      'status': status == AttendanceStatus.present ? 'present' : 'absent',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _generateUniqueCode() async {
    while (true) {
      final code = _codeGen.generate();
      final snap = await _db
          .collection('attendanceSessions')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return code;
    }
  }

  // ── Seed ───────────────────────────────────────────────────────────────────

  Future<void> seedIfNeeded() async {
    final doc = await _db.collection('lecturers').doc('LE210145').get();
    if (!doc.exists) await _seedData();
    final sessions =
        await _db.collection('attendanceSessions').limit(1).get();
    if (sessions.docs.isEmpty) await _seedSampleAttendance();
  }

  Future<void> _seedSampleAttendance() async {
    final sampleSessions = [
      {
        'courseID': 'BCI2013',
        'courseName': 'Programming Technique',
        'section': '01B',
        'date': '05/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'code': 'DEMO01',
      },
      {
        'courseID': 'BCI2013',
        'courseName': 'Programming Technique',
        'section': '01B',
        'date': '12/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'code': 'DEMO02',
      },
      {
        'courseID': 'BCI2013',
        'courseName': 'Programming Technique',
        'section': '01B',
        'date': '19/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'code': 'DEMO03',
      },
      {
        'courseID': 'BCS1023',
        'courseName': 'Software Engineering',
        'section': '02A',
        'date': '20/04/2026',
        'timeLabel': '2:00PM - 4:00PM',
        'code': 'DEMO04',
      },
      {
        'courseID': 'BCS1023',
        'courseName': 'Software Engineering',
        'section': '02A',
        'date': '27/04/2026',
        'timeLabel': '2:00PM - 4:00PM',
        'code': 'DEMO05',
      },
    ];

    final sessionBatch = _db.batch();
    final sessionIds = <String>[];
    for (final s in sampleSessions) {
      final ref = _db.collection('attendanceSessions').doc();
      sessionIds.add(ref.id);
      sessionBatch.set(ref, {
        ...s,
        'lecturerID': 'LE210145',
        'locationName': 'DK1',
        'latitude': 4.2105,
        'longitude': 101.9758,
        'qrSeed':
            '${s['courseID']}-${s['section']}-${s['date']}-${s['code']}',
        'generatedAt': FieldValue.serverTimestamp(),
      });
    }
    await sessionBatch.commit();

    final recordBatch = _db.batch();
    final sampleStatuses = [
      'present',
      'present',
      'absent',
      'present',
      'absent',
    ];
    for (var i = 0; i < sampleSessions.length; i++) {
      final s = sampleSessions[i];
      final recordId = '${sessionIds[i]}_A20CS1001';
      recordBatch.set(_db.collection('attendanceRecords').doc(recordId), {
        'sessionID': sessionIds[i],
        'courseID': s['courseID'],
        'courseName': s['courseName'],
        'section': s['section'],
        'date': s['date'],
        'timeLabel': s['timeLabel'],
        'studentID': 'A20CS1001',
        'matricID': 'CD21145',
        'studentName': 'Ahmad Faiz bin Abdullah',
        'status': sampleStatuses[i],
        'submittedAt': sampleStatuses[i] == 'present'
            ? FieldValue.serverTimestamp()
            : null,
      });
    }
    await recordBatch.commit();
  }

  Future<void> _seedData() async {
    final batch = _db.batch();

    // Lecturers — ERD field names
    batch.set(_db.collection('lecturers').doc('LE210145'), {
      'lecturerID': 'LE210145',
      'lecturer_name': 'Dr. Hafiz bin Abdullah',
      'department': 'Jabatan Sains Komputer, FKOM',
      'email': 'hafiz@utm.my',
      'semesterLabel': 'Semester 2, 2025/2026',
      'username': 'LE210145',
      'password': 'lecturer123',
    });

    // Students — ERD field names
    batch.set(_db.collection('students').doc('A20CS1001'), {
      'studentID': 'A20CS1001',
      'studentName': 'Ahmad Faiz bin Abdullah',
      'matricId': 'CD21145',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'semester': 'Semester 2, 2025/2026',
      'lecturerID': 'LE210145',
      'total_credits': 92,
      'password': 'student123',
    });
    batch.set(_db.collection('students').doc('A20CS1002'), {
      'studentID': 'A20CS1002',
      'studentName': 'Amalin Aisyah binti Aziz',
      'matricId': 'CD21100',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'semester': 'Semester 2, 2025/2026',
      'lecturerID': 'LE210145',
      'total_credits': 88,
      'password': 'student123',
    });
    batch.set(_db.collection('students').doc('A20CS1003'), {
      'studentID': 'A20CS1003',
      'studentName': 'Adani binti Mohd Fadzil',
      'matricId': 'CD21079',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'semester': 'Semester 2, 2025/2026',
      'lecturerID': 'LE210145',
      'total_credits': 85,
      'password': 'student123',
    });
    batch.set(_db.collection('students').doc('A20CS1004'), {
      'studentID': 'A20CS1004',
      'studentName': 'Ahmad Imran',
      'matricId': 'CD210145',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'semester': 'Semester 2, 2025/2026',
      'lecturerID': 'LE210145',
      'total_credits': 90,
      'password': 'student123',
    });

    // Courses — ERD field names
    final courses = [
      {
        'course_id': 'BCS1023',
        'course_name': 'Software Engineering',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 42,
        'lecturerID': 'LE210145',
        'lecturer_name': 'Dr. Hafiz bin Abdullah',
        'credits': 3,
        'description': 'Pengenalan kepada prinsip dan amalan kejuruteraan perisian moden.',
        'is_published': true,
        'staffID': 'REG001',
      },
      {
        'course_id': 'BCS3013',
        'course_name': 'Introduction to Computer Science',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 45,
        'lecturerID': 'LE210145',
        'lecturer_name': 'Dr. Hafiz bin Abdullah',
        'credits': 3,
        'description': 'Asas-asas dalam sains komputer dan pengaturcaraan.',
        'is_published': true,
        'staffID': 'REG001',
      },
      {
        'course_id': 'BCI2013',
        'course_name': 'Programming Technique',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 38,
        'lecturerID': 'LE210145',
        'lecturer_name': 'Dr. Hafiz bin Abdullah',
        'credits': 3,
        'description': 'Teknik-teknik asas pengaturcaraan menggunakan bahasa pengaturcaraan moden.',
        'is_published': true,
        'staffID': 'REG001',
      },
      {
        'course_id': 'BCS3023',
        'course_name': 'Object Oriented Programming',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 42,
        'lecturerID': 'LE210145',
        'lecturer_name': 'Dr. Hafiz bin Abdullah',
        'credits': 3,
        'description': 'Konsep dan amalan pengaturcaraan berorientasikan objek.',
        'is_published': true,
        'staffID': 'REG001',
      },
      {
        'course_id': 'KCS3023',
        'course_name': '3D Printing Design',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 29,
        'lecturerID': 'LE210145',
        'lecturer_name': 'Dr. Hafiz bin Abdullah',
        'credits': 2,
        'description': 'Reka bentuk dan percetakan 3D menggunakan teknologi terkini.',
        'is_published': true,
        'staffID': 'REG001',
      },
    ];
    for (final c in courses) {
      batch.set(
        _db.collection('courses').doc(c['course_id'] as String),
        c,
      );
    }

    await batch.commit();

    // Schedules — keep courseCode field (implementation detail, not in ERD)
    final schedules = [
      {
        'courseCode': 'BCS1023',
        'section': '02A',
        'date': '20/04/2026',
        'timeLabel': '2:00PM - 4:00PM',
        'locationName': 'DK1',
        'latitude': 4.2105,
        'longitude': 101.9758,
      },
      {
        'courseCode': 'BCS3013',
        'section': '02A',
        'date': '03/04/2026',
        'timeLabel': '08:00AM - 10:00AM',
        'locationName': 'DK1',
        'latitude': 4.2105,
        'longitude': 101.9758,
      },
      {
        'courseCode': 'BCS3013',
        'section': '02A',
        'date': '10/04/2026',
        'timeLabel': '08:00AM - 10:00AM',
        'locationName': 'DK1',
        'latitude': 4.2105,
        'longitude': 101.9758,
      },
      {
        'courseCode': 'BCI2013',
        'section': '01B',
        'date': '05/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'locationName': 'MK2',
        'latitude': 4.2107,
        'longitude': 101.9759,
      },
      {
        'courseCode': 'BCI2013',
        'section': '01B',
        'date': '12/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'locationName': 'MK2',
        'latitude': 4.2107,
        'longitude': 101.9759,
      },
      {
        'courseCode': 'BCS3023',
        'section': '03A',
        'date': '08/04/2026',
        'timeLabel': '02:00PM - 04:00PM',
        'locationName': 'DK1',
        'latitude': 4.2105,
        'longitude': 101.9758,
      },
      {
        'courseCode': 'KCS3023',
        'section': '01A',
        'date': '15/04/2026',
        'timeLabel': '09:00AM - 11:00AM',
        'locationName': 'MK2',
        'latitude': 4.2107,
        'longitude': 101.9759,
      },
    ];

    final schedBatch = _db.batch();
    for (final s in schedules) {
      schedBatch.set(_db.collection('schedules').doc(), s);
    }
    await schedBatch.commit();

    // Enrollments — ERD field names
    final enrollBatch = _db.batch();
    final studentEnrollments = [
      {
        'studentID': 'A20CS1001',
        'matricId': 'CD21145',
        'studentName': 'Ahmad Faiz bin Abdullah',
      },
      {
        'studentID': 'A20CS1002',
        'matricId': 'CD21100',
        'studentName': 'Amalin Aisyah binti Aziz',
      },
      {
        'studentID': 'A20CS1003',
        'matricId': 'CD21079',
        'studentName': 'Adani binti Mohd Fadzil',
      },
      {
        'studentID': 'A20CS1004',
        'matricId': 'CD210145',
        'studentName': 'Ahmad Imran',
      },
    ];

    for (final courseCode in [
      'BCS1023',
      'BCS3013',
      'BCI2013',
      'BCS3023',
      'KCS3023',
    ]) {
      final courseData = courses.firstWhere(
        (c) => c['course_id'] == courseCode,
      );
      for (final s in studentEnrollments) {
        final enrollId = '${s['studentID']}_$courseCode';
        enrollBatch.set(_db.collection('enrollments').doc(enrollId), {
          'studentID': s['studentID'],
          'matricId': s['matricId'],
          'studentName': s['studentName'],
          'course_id': courseCode,
          'courseName': courseData['course_name'],
          'lecturerName': courseData['lecturer_name'],
          'curriculum': courseData['curriculum'],
          'semester': 'Semester 2, 2025/2026',
          'status': 'active',
          'is_registration_open': true,
        });
      }
    }
    await enrollBatch.commit();
  }
}

class _AttendanceCodeGenerator {
  final Random _random = Random();

  String generate() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}
