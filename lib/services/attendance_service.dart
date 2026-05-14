import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/manage_attendance/attendance_models.dart';

// ── Firestore Mappers (Firebase logic isolated here, not in models) ────────────

LecturerProfile _lecturerFromDoc(Map<String, dynamic> d) => LecturerProfile(
  name: d['name'] ?? '',
  lecturerId: d['lecturerId'] ?? '',
  title: d['title'] ?? '',
  semesterLabel: d['semesterLabel'] ?? '',
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
      courseName: d['courseName'] ?? '',
      courseCode: d['courseCode'] ?? '',
      curriculum: d['curriculum'] ?? '',
      semesterLabel: d['semesterLabel'] ?? '',
      enrolledCount: (d['enrolledCount'] ?? 0) as int,
      lecturerId: d['lecturerId'] ?? '',
      lecturerName: d['lecturerName'] ?? '',
      schedules: schedules,
    );

StudentAttendanceRecord _recordFromDoc(String id, Map<String, dynamic> d) =>
    StudentAttendanceRecord(
      recordId: id,
      matricId: d['matricId'] ?? '',
      name: d['studentName'] ?? '',
      studentId: d['studentId'] ?? '',
      status: d['status'] == 'present'
          ? AttendanceStatus.present
          : AttendanceStatus.absent,
    );

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
    final snap = await _db
        .collection('courses')
        .where('lecturerId', isEqualTo: lecturerId)
        .get();

    final courses = <Course>[];
    for (final doc in snap.docs) {
      final schedules = await _fetchSchedules(doc.id);
      courses.add(_courseFromDoc(doc.data(), schedules));
    }
    return courses;
  }

  Future<List<SessionOption>> _fetchSchedules(String courseCode) async {
    final snap = await _db
        .collection('schedules')
        .where('courseCode', isEqualTo: courseCode)
        .get();
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
      'courseCode': course.courseCode,
      'courseName': course.courseName,
      'scheduleId': session.scheduleId,
      'section': session.section,
      'date': session.date,
      'timeLabel': session.timeLabel,
      'code': code,
      'qrSeed': qrSeed,
      'generatedAt': FieldValue.serverTimestamp(),
      'lecturerId': lecturerId,
      'locationName': session.location.name,
      'latitude': session.location.latitude,
      'longitude': session.location.longitude,
    };

    final ref = await _db.collection('attendanceSessions').add(sessionData);
    await _createAbsentRecordsForSession(
      sessionId: ref.id,
      course: course,
      session: session,
    );

    return AttendanceSession(
      sessionId: ref.id,
      course: course,
      session: session,
      code: code,
      generatedAt: DateTime.now(),
      qrSeed: qrSeed,
    );
  }

  Future<void> _createAbsentRecordsForSession({
    required String sessionId,
    required Course course,
    required SessionOption session,
  }) async {
    final enrollSnap = await _db
        .collection('enrollments')
        .where('courseCode', isEqualTo: course.courseCode)
        .get();

    final batch = _db.batch();
    for (final enroll in enrollSnap.docs) {
      final data = enroll.data();
      final recordId = '${sessionId}_${data['studentId']}';
      final ref = _db.collection('attendanceRecords').doc(recordId);
      batch.set(ref, {
        'sessionId': sessionId,
        'courseCode': course.courseCode,
        'courseName': course.courseName,
        'section': session.section,
        'date': session.date,
        'timeLabel': session.timeLabel,
        'studentId': data['studentId'] ?? '',
        'matricId': data['matricId'] ?? '',
        'studentName': data['studentName'] ?? '',
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
    final sessionSnap = await _db
        .collection('attendanceSessions')
        .where('courseCode', isEqualTo: course.courseCode)
        .where('section', isEqualTo: session.section)
        .where('date', isEqualTo: session.date)
        .where('timeLabel', isEqualTo: session.timeLabel)
        .limit(1)
        .get();

    if (sessionSnap.docs.isEmpty) return [];

    final sessionId = sessionSnap.docs.first.id;
    final recordsSnap = await _db
        .collection('attendanceRecords')
        .where('sessionId', isEqualTo: sessionId)
        .get();

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

  Future<void> seedIfNeeded() async {
    final doc = await _db.collection('lecturers').doc('LE210145').get();
    if (!doc.exists) await _seedData();
    final sessions = await _db.collection('attendanceSessions').limit(1).get();
    if (sessions.docs.isEmpty) await _seedSampleAttendance();
  }

  Future<void> _seedSampleAttendance() async {
    final sampleSessions = [
      {
        'courseCode': 'BCI2013',
        'courseName': 'Programming Technique',
        'section': '01B',
        'date': '05/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'code': 'DEMO01',
      },
      {
        'courseCode': 'BCI2013',
        'courseName': 'Programming Technique',
        'section': '01B',
        'date': '12/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'code': 'DEMO02',
      },
      {
        'courseCode': 'BCI2013',
        'courseName': 'Programming Technique',
        'section': '01B',
        'date': '19/04/2026',
        'timeLabel': '10:30AM - 12:30PM',
        'code': 'DEMO03',
      },
      {
        'courseCode': 'BCS1023',
        'courseName': 'Software Engineering',
        'section': '02A',
        'date': '20/04/2026',
        'timeLabel': '2:00PM - 4:00PM',
        'code': 'DEMO04',
      },
      {
        'courseCode': 'BCS1023',
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
        'lecturerId': 'LE210145',
        'locationName': 'DK1',
        'latitude': 4.2105,
        'longitude': 101.9758,
        'qrSeed':
            '${s['courseCode']}-${s['section']}-${s['date']}-${s['code']}',
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
        'sessionId': sessionIds[i],
        'courseCode': s['courseCode'],
        'courseName': s['courseName'],
        'section': s['section'],
        'date': s['date'],
        'timeLabel': s['timeLabel'],
        'studentId': 'A20CS1001',
        'matricId': 'CD21145',
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

    // Lecturers
    batch.set(_db.collection('lecturers').doc('LE210145'), {
      'name': 'Dr. Hafiz bin Abdullah',
      'lecturerId': 'LE210145',
      'title': 'Senior Lecturer, FKOM',
      'semesterLabel': 'Semester 2, 2025/2026',
    });

    // Students
    batch.set(_db.collection('students').doc('A20CS1001'), {
      'name': 'Ahmad Faiz bin Abdullah',
      'studentId': 'A20CS1001',
      'matricId': 'CD21145',
      'program': 'Bachelor of Computer Science',
    });
    batch.set(_db.collection('students').doc('A20CS1002'), {
      'name': 'Amalin Aisyah binti Aziz',
      'studentId': 'A20CS1002',
      'matricId': 'CD21100',
      'program': 'Bachelor of Computer Science',
    });
    batch.set(_db.collection('students').doc('A20CS1003'), {
      'name': 'Adani binti Mohd Fadzil',
      'studentId': 'A20CS1003',
      'matricId': 'CD21079',
      'program': 'Bachelor of Computer Science',
    });

    // Courses
    final courses = [
      {
        'courseName': 'Software Engineering',
        'courseCode': 'BCS1023',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 42,
        'lecturerId': 'LE210145',
        'lecturerName': 'Dr. Hafiz bin Abdullah',
      },
      {
        'courseName': 'Introduction to Computer Science',
        'courseCode': 'BCS3013',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 45,
        'lecturerId': 'LE210145',
        'lecturerName': 'Dr. Hafiz bin Abdullah',
      },
      {
        'courseName': 'Programming Technique',
        'courseCode': 'BCI2013',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 38,
        'lecturerId': 'LE210145',
        'lecturerName': 'Dr. Hafiz bin Abdullah',
      },
      {
        'courseName': 'Object Oriented Programming',
        'courseCode': 'BCS3023',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 42,
        'lecturerId': 'LE210145',
        'lecturerName': 'Dr. Hafiz bin Abdullah',
      },
      {
        'courseName': '3D Printing Design',
        'courseCode': 'KCS3023',
        'curriculum': 'Curriculum 2020',
        'semesterLabel': 'Semester 2, 2025/2026',
        'enrolledCount': 29,
        'lecturerId': 'LE210145',
        'lecturerName': 'Dr. Hafiz bin Abdullah',
      },
    ];
    for (final c in courses) {
      batch.set(_db.collection('courses').doc(c['courseCode'] as String), c);
    }

    await batch.commit();

    // Schedules (written separately — nested collections not supported in batch across collections cleanly)
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

    // Enrollments
    final enrollBatch = _db.batch();
    final studentEnrollments = [
      {
        'studentId': 'A20CS1001',
        'matricId': 'CD21145',
        'studentName': 'Ahmad Faiz bin Abdullah',
      },
      {
        'studentId': 'A20CS1002',
        'matricId': 'CD21100',
        'studentName': 'Amalin Aisyah binti Aziz',
      },
      {
        'studentId': 'A20CS1003',
        'matricId': 'CD21079',
        'studentName': 'Adani binti Mohd Fadzil',
      },
    ];

    for (final courseCode in [
      'BCS1023',
      'BCS3013',
      'BCI2013',
      'BCS3023',
      'KCS3023',
    ]) {
      final courseName =
          courses.firstWhere((c) => c['courseCode'] == courseCode)['courseName']
              as String;
      for (final s in studentEnrollments) {
        final enrollId = '${s['studentId']}_$courseCode';
        enrollBatch.set(_db.collection('enrollments').doc(enrollId), {
          'studentId': s['studentId'],
          'matricId': s['matricId'],
          'studentName': s['studentName'],
          'courseCode': courseCode,
          'courseName': courseName,
          'lecturerName': 'Dr. Hafiz bin Abdullah',
          'curriculum': 'Curriculum 2020',
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
