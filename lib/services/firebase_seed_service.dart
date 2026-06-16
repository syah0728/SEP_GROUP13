import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds all ERD collections that are NOT handled by FirebaseAttendanceService.
/// Collections covered here:
///   registrars, adabStaff, treasury, modules, claims,
///   studentFees, payments, notifications, semesterSummaries
/// Also updates existing collections with missing ERD fields:
///   students (password, semester, lecturerID, total_credits, programme)
///   courses  (credits, description, is_published, staffID)
///   lecturers (email, department, lecturer_name)
///   enrollments (semester, status, is_registration_open)
class FirebaseSeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedIfNeeded() async {
    final snap = await _db.collection('registrars').limit(1).get();
    if (snap.docs.isEmpty) await _seedAll();
    await _migrateStudentIDs();
    await _seedAttendanceIfNeeded();
  }

  // Migrates existing student docs: copies matricId value into studentID,
  // then removes matricId and program fields.
  Future<void> _migrateStudentIDs() async {
    final snap = await _db.collection('students').get();
    final batch = _db.batch();
    bool dirty = false;
    for (final doc in snap.docs) {
      final data = doc.data();
      final matric = (data['matricId'] ?? data['matricID']) as String?;
      if (matric == null) continue; // already migrated
      batch.update(doc.reference, {
        'studentID': matric.toUpperCase(),
        'matricId': FieldValue.delete(),
        'matricID': FieldValue.delete(),
        'program': FieldValue.delete(),
      });
      dirty = true;
    }
    if (dirty) await batch.commit();
  }

  Future<void> _seedAll() async {
    // Batch 1: staff & treasury
    final b1 = _db.batch();
    _addRegistrars(b1);
    _addAdabStaff(b1);
    _addTreasury(b1);
    await b1.commit();

    // Batch 2: co-curriculum
    final b2 = _db.batch();
    _addModules(b2);
    _addClaims(b2);
    await b2.commit();

    // Batch 3: financial
    final b3 = _db.batch();
    _addStudentFees(b3);
    _addPayments(b3);
    _addSemesterSummaries(b3);
    await b3.commit();

    // Batch 4: notifications
    final b4 = _db.batch();
    _addNotifications(b4);
    await b4.commit();

    // Update existing collections with missing ERD fields
    await _updateLecturers();
    await _updateStudents();
    await _updateCourses();
    await _updateEnrollments();
  }

  // ── FK_Registrar ────────────────────────────────────────────────────────────

  void _addRegistrars(WriteBatch batch) {
    final registrars = [
      {
        'staffID': 'REG001',
        'staff_name': 'Pn. Norzaihan binti Mohd Zain',
        'username': 'norzaihan',
        'password': 'reg123',
        'position': 'Senior Registrar',
      },
      {
        'staffID': 'REG002',
        'staff_name': 'En. Kamarudin bin Sulaiman',
        'username': 'kamarudin',
        'password': 'reg456',
        'position': 'Deputy Registrar',
      },
    ];
    for (final r in registrars) {
      batch.set(
        _db.collection('registrars').doc(r['staffID'] as String),
        r,
      );
    }
  }

  // ── Adab_Staff ──────────────────────────────────────────────────────────────

  void _addAdabStaff(WriteBatch batch) {
    final staff = [
      {
        'adabID': 'ADAB001',
        'staffName': 'En. Azhar bin Hamid',
        'username': 'azhar_adab',
        'password': 'adab123',
        'email': 'azhar.adab@utm.my',
      },
      {
        'adabID': 'ADAB002',
        'staffName': 'Pn. Siti Rohana binti Kassim',
        'username': 'sitirohana',
        'password': 'adab456',
        'email': 'sitirohana@utm.my',
      },
    ];
    for (final s in staff) {
      batch.set(
        _db.collection('adabStaff').doc(s['adabID'] as String),
        s,
      );
    }
  }

  // ── Treasury ────────────────────────────────────────────────────────────────

  void _addTreasury(WriteBatch batch) {
    batch.set(_db.collection('treasury').doc('TRES001'), {
      'treasuryID': 'TRES001',
      'username': 'treasury_utm',
      'password': 'tres123',
      'treasuryName': 'Pejabat Perbendaharaan UTM JB',
      'createdAt': FieldValue.serverTimestamp(),
      'paymentID': 'PAY001',
      'notificationID': 'NOTIF003',
    });
  }

  // ── module (Co-curriculum) ──────────────────────────────────────────────────

  void _addModules(WriteBatch batch) {
    final modules = [
      {
        'moduleId': 'MOD001',
        'title': 'Bengkel Kepimpinan UTM',
        'date': '15 May 2026',
        'startTime': '8:00 AM',
        'endTime': '5:00 PM',
        'venue': 'Dewan Utama UTM',
        'maxParticipants': 100,
        'registeredCount': 45,
        'lecturerId': 'LE210145',
        'lecturer': 'Dr. Hafiz bin Abdullah',
        'code': '',
      },
      {
        'moduleId': 'MOD002',
        'title': 'Pertandingan Sukan Antara Kolej',
        'date': '20 May 2026',
        'startTime': '9:00 AM',
        'endTime': '6:00 PM',
        'venue': 'Stadium UTM',
        'maxParticipants': 200,
        'registeredCount': 120,
        'lecturerId': 'LE210145',
        'lecturer': 'Dr. Hafiz bin Abdullah',
        'code': '',
      },
      {
        'moduleId': 'MOD003',
        'title': 'Program Khidmat Masyarakat',
        'date': '25 May 2026',
        'startTime': '8:00 AM',
        'endTime': '1:00 PM',
        'venue': 'Taman Perumahan Skudai',
        'maxParticipants': 50,
        'registeredCount': 38,
        'lecturerId': 'LE210145',
        'lecturer': 'Dr. Hafiz bin Abdullah',
        'code': '',
      },
      {
        'moduleId': 'MOD004',
        'title': 'Seminar Inovasi Pelajar',
        'date': '10 Jun 2026',
        'startTime': '9:00 AM',
        'endTime': '4:00 PM',
        'venue': 'Bilik Seminar FKOM',
        'maxParticipants': 80,
        'registeredCount': 55,
        'lecturerId': 'LE210145',
        'lecturer': 'Dr. Hafiz bin Abdullah',
        'code': '',
      },
    ];
    for (final m in modules) {
      batch.set(
        _db.collection('modules').doc(m['moduleId'] as String),
        m,
      );
    }
  }

  // ── Claim ───────────────────────────────────────────────────────────────────

  void _addClaims(WriteBatch batch) {
    final claims = [
      {
        'claimID': 'CLM001',
        'studentId': 'A20CS1001',
        'studentName': 'Ahmad Faiz bin Abdullah',
        'matricNumber': 'CD21145',
        'moduleId': 'MOD001',
        'adabId': 'ADAB001',
        'submittedDate': '16/05/2026',
        'status': 'pending',
        'modules': ['Bengkel Kepimpinan UTM'],
        'grade': 'A',
        'marks': '90%',
        'rejectReason': '',
      },
      {
        'claimID': 'CLM002',
        'studentId': 'A20CS1002',
        'studentName': 'Amalin Aisyah binti Aziz',
        'matricNumber': 'CD21100',
        'moduleId': 'MOD002',
        'adabId': 'ADAB001',
        'submittedDate': '21/05/2026',
        'status': 'approved',
        'modules': ['Pertandingan Sukan Antara Kolej'],
        'grade': 'B+',
        'marks': '75%',
        'rejectReason': '',
      },
      {
        'claimID': 'CLM003',
        'studentId': 'A20CS1003',
        'studentName': 'Adani binti Mohd Fadzil',
        'matricNumber': 'CD21079',
        'moduleId': 'MOD003',
        'adabId': 'ADAB002',
        'submittedDate': '26/05/2026',
        'status': 'rejected',
        'modules': ['Program Khidmat Masyarakat'],
        'grade': '',
        'marks': '0%',
        'rejectReason': 'Dokumen sokongan tidak lengkap',
      },
      {
        'claimID': 'CLM004',
        'studentId': 'A20CS1001',
        'studentName': 'Ahmad Faiz bin Abdullah',
        'matricNumber': 'CD21145',
        'moduleId': 'MOD004',
        'adabId': 'ADAB002',
        'submittedDate': '11/06/2026',
        'status': 'pending',
        'modules': ['Seminar Inovasi Pelajar'],
        'grade': 'A-',
        'marks': '85%',
        'rejectReason': '',
      },
    ];
    for (final c in claims) {
      batch.set(
        _db.collection('claims').doc(c['claimID'] as String),
        c,
      );
    }
  }

  // ── Student Fee ─────────────────────────────────────────────────────────────

  void _addStudentFees(WriteBatch batch) {
    final fees = [
      {
        'studentFeeID': 'FEE_A20CS1001',
        'studentID': 'A20CS1001',
        'semester': 'Semester 2, 2025/2026',
        'educationFee': 1500.00,
        'hostelFee': 800.00,
        'otherFee': 150.00,
        'totalAmount': 2450.00,
        'paidAmount': 2450.00,
        'paymentStatus': 'paid',
        'paymentDeadline': '01/03/2026',
        'deadlineOverdue': false,
        'paymentID': 'PAY001',
      },
      {
        'studentFeeID': 'FEE_A20CS1002',
        'studentID': 'A20CS1002',
        'semester': 'Semester 2, 2025/2026',
        'educationFee': 1500.00,
        'hostelFee': 800.00,
        'otherFee': 150.00,
        'totalAmount': 2450.00,
        'paidAmount': 1500.00,
        'paymentStatus': 'partial',
        'paymentDeadline': '01/03/2026',
        'deadlineOverdue': true,
        'paymentID': 'PAY002',
      },
      {
        'studentFeeID': 'FEE_A20CS1003',
        'studentID': 'A20CS1003',
        'semester': 'Semester 2, 2025/2026',
        'educationFee': 1500.00,
        'hostelFee': 800.00,
        'otherFee': 150.00,
        'totalAmount': 2450.00,
        'paidAmount': 0.00,
        'paymentStatus': 'unpaid',
        'paymentDeadline': '01/03/2026',
        'deadlineOverdue': true,
        'paymentID': '',
      },
    ];
    for (final f in fees) {
      batch.set(
        _db.collection('studentFees').doc(f['studentFeeID'] as String),
        f,
      );
    }
  }

  // ── Payment ─────────────────────────────────────────────────────────────────

  void _addPayments(WriteBatch batch) {
    final payments = [
      {
        'paymentID': 'PAY001',
        'studentID': 'A20CS1001',
        'studentName': 'Ahmad Faiz bin Abdullah',
        'semester': 'Semester 2, 2025/2026',
        'educationFee': 1500.00,
        'hostelFee': 800.00,
        'otherFee': 150.00,
        'totalAmount': 2450.00,
        'paymentMethod': 'Online Transfer',
        'receiptNo': 'RCP20260301001',
        'paymentStatus': 'success',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'paymentID': 'PAY002',
        'studentID': 'A20CS1002',
        'studentName': 'Amalin Aisyah binti Aziz',
        'semester': 'Semester 2, 2025/2026',
        'educationFee': 1500.00,
        'hostelFee': 0.00,
        'otherFee': 0.00,
        'totalAmount': 1500.00,
        'paymentMethod': 'Credit Card',
        'receiptNo': 'RCP20260315002',
        'paymentStatus': 'partial',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];
    for (final p in payments) {
      batch.set(
        _db.collection('payments').doc(p['paymentID'] as String),
        p,
      );
    }
  }

  // ── Notification ────────────────────────────────────────────────────────────

  void _addNotifications(WriteBatch batch) {
    final notifications = [
      {
        'notificationID': 'NOTIF001',
        'studentID': 'A20CS1001',
        'title': 'Pembayaran Yuran Diterima',
        'message':
            'Bayaran yuran Semester 2, 2025/2026 berjumlah RM2,450 telah berjaya diterima.',
        'type': 'payment',
        'isRead': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'notificationID': 'NOTIF002',
        'studentID': 'A20CS1001',
        'title': 'Tuntutan Ko-Kurikulum Diproses',
        'message':
            'Tuntutan anda untuk Bengkel Kepimpinan UTM sedang diproses oleh pihak ADAB.',
        'type': 'claim',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'notificationID': 'NOTIF003',
        'studentID': 'A20CS1002',
        'title': 'Peringatan: Baki Yuran Belum Dijelaskan',
        'message':
            'Anda masih mempunyai baki yuran RM950 untuk Semester 2, 2025/2026. Sila jelaskan sebelum 30/05/2026.',
        'type': 'payment',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'notificationID': 'NOTIF004',
        'studentID': 'A20CS1003',
        'title': 'Tuntutan Ko-Kurikulum Ditolak',
        'message':
            'Tuntutan Program Khidmat Masyarakat anda ditolak. Sebab: Dokumen sokongan tidak lengkap.',
        'type': 'claim',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'notificationID': 'NOTIF005',
        'studentID': 'A20CS1003',
        'title': 'Peringatan: Yuran Belum Dibayar',
        'message':
            'Yuran Semester 2, 2025/2026 berjumlah RM2,450 masih belum dibayar. Sila hubungi Pejabat Perbendaharaan.',
        'type': 'payment',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];
    for (final n in notifications) {
      batch.set(
        _db.collection('notifications').doc(n['notificationID'] as String),
        n,
      );
    }
  }

  // ── Semester Summary ────────────────────────────────────────────────────────

  void _addSemesterSummaries(WriteBatch batch) {
    batch.set(_db.collection('semesterSummaries').doc('SUM_S2_2526'), {
      'summaryID': 'SUM_S2_2526',
      'semester': 'Semester 2, 2025/2026',
      'totalRevenue': 7350.00,
      'pendingCollection': 2900.00,
      'collectionRate': 60.7,
      'totalPaid': 4450.00,
      'totalPending': 2900.00,
      'totalBlocked': 0.00,
      'updatedAt': FieldValue.serverTimestamp(),
      'paymentID': 'PAY001',
    });
    batch.set(_db.collection('semesterSummaries').doc('SUM_S1_2526'), {
      'summaryID': 'SUM_S1_2526',
      'semester': 'Semester 1, 2025/2026',
      'totalRevenue': 7350.00,
      'pendingCollection': 0.00,
      'collectionRate': 100.0,
      'totalPaid': 7350.00,
      'totalPending': 0.00,
      'totalBlocked': 0.00,
      'updatedAt': FieldValue.serverTimestamp(),
      'paymentID': '',
    });
  }

  // ── Update existing collections with missing ERD fields ─────────────────────

  Future<void> _updateLecturers() async {
    await _db.collection('lecturers').doc('LE210145').update({
      'lecturer_name': 'Dr. Hafiz bin Abdullah',
      'email': 'hafiz@utm.my',
      'department': 'Jabatan Sains Komputer, FKOM',
    });
  }

  Future<void> _updateStudents() async {
    final updates = <String, Map<String, dynamic>>{
      'A20CS1001': {
        'studentName': 'Ahmad Faiz bin Abdullah',
        'programme': 'Bachelor of Computer Science (Software Engineering)',
        'password': 'student123',
        'semester': 'Semester 2, 2025/2026',
        'lecturerID': 'LE210145',
        'total_credits': 92,
      },
      'A20CS1002': {
        'studentName': 'Amalin Aisyah binti Aziz',
        'programme': 'Bachelor of Computer Science (Software Engineering)',
        'password': 'student123',
        'semester': 'Semester 2, 2025/2026',
        'lecturerID': 'LE210145',
        'total_credits': 88,
      },
      'A20CS1003': {
        'studentName': 'Adani binti Mohd Fadzil',
        'programme': 'Bachelor of Computer Science (Software Engineering)',
        'password': 'student123',
        'semester': 'Semester 2, 2025/2026',
        'lecturerID': 'LE210145',
        'total_credits': 85,
      },
    };
    for (final entry in updates.entries) {
      await _db.collection('students').doc(entry.key).update(entry.value);
    }
  }

  Future<void> _updateCourses() async {
    final courseData = <String, Map<String, dynamic>>{
      'BCS1023': {
        'credits': 3,
        'description':
            'Pengenalan kepada prinsip dan amalan kejuruteraan perisian moden.',
        'is_published': true,
        'staffID': 'REG001',
      },
      'BCS3013': {
        'credits': 3,
        'description': 'Asas-asas dalam sains komputer dan pengaturcaraan.',
        'is_published': true,
        'staffID': 'REG001',
      },
      'BCI2013': {
        'credits': 3,
        'description':
            'Teknik-teknik asas pengaturcaraan menggunakan bahasa pengaturcaraan moden.',
        'is_published': true,
        'staffID': 'REG001',
      },
      'BCS3023': {
        'credits': 3,
        'description': 'Konsep dan amalan pengaturcaraan berorientasikan objek.',
        'is_published': true,
        'staffID': 'REG001',
      },
      'KCS3023': {
        'credits': 2,
        'description':
            'Reka bentuk dan percetakan 3D menggunakan teknologi terkini.',
        'is_published': true,
        'staffID': 'REG001',
      },
    };
    for (final entry in courseData.entries) {
      await _db.collection('courses').doc(entry.key).update(entry.value);
    }
  }

  // Seeds attendance records for the 3 seeded claim students.
  // Runs independently so it works even if the main seed already ran.
  Future<void> _seedAttendanceIfNeeded() async {
    final snap = await _db.collection('attendance').doc('ATT001').get();
    if (snap.exists) return;
    final batch = _db.batch();
    _addAttendance(batch);
    await batch.commit();
  }

  void _addAttendance(WriteBatch batch) {
    // Ahmad Faiz — attended 2 modules (matches CLM001 + CLM004)
    batch.set(_db.collection('attendance').doc('ATT001'), {
      'studentName': 'Ahmad Faiz bin Abdullah',
      'matricNumber': 'CD21145',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'totalRegistered': 2,
      'totalAttended': 2,
      'records': [
        {
          'moduleName': 'Bengkel Kepimpinan UTM',
          'date': '15/05/2026',
          'checkInTime': '8:15 AM',
          'isPresent': true,
        },
        {
          'moduleName': 'Seminar Inovasi Pelajar',
          'date': '10/06/2026',
          'checkInTime': '9:05 AM',
          'isPresent': true,
        },
      ],
    });

    // Amalin Aisyah — attended 1 module (matches CLM002)
    batch.set(_db.collection('attendance').doc('ATT002'), {
      'studentName': 'Amalin Aisyah binti Aziz',
      'matricNumber': 'CD21100',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'totalRegistered': 1,
      'totalAttended': 1,
      'records': [
        {
          'moduleName': 'Pertandingan Sukan Antara Kolej',
          'date': '20/05/2026',
          'checkInTime': '9:10 AM',
          'isPresent': true,
        },
      ],
    });

    // Adani — attended 1 module (matches CLM003)
    batch.set(_db.collection('attendance').doc('ATT003'), {
      'studentName': 'Adani binti Mohd Fadzil',
      'matricNumber': 'CD21079',
      'programme': 'Bachelor of Computer Science (Software Engineering)',
      'totalRegistered': 1,
      'totalAttended': 1,
      'records': [
        {
          'moduleName': 'Program Khidmat Masyarakat',
          'date': '25/05/2026',
          'checkInTime': '8:30 AM',
          'isPresent': true,
        },
      ],
    });
  }

  Future<void> _updateEnrollments() async {
    final snap = await _db.collection('enrollments').get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'semester': 'Semester 2, 2025/2026',
        'status': 'active',
        'is_registration_open': true,
      });
    }
    await batch.commit();
  }
}
