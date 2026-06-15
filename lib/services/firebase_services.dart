// services/firebase_services.dart
// Central service for all Firestore database operations.
// Used by adab screens (manage claims, modules, attendance)
// and student screens (view modules, submit claims).

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manage_cocurriculum/module.dart';
import '../models/manage_cocurriculum/claim.dart';
import '../models/manage_cocurriculum/attendance.dart';

class FirebaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ---------- MODULES ----------

  Stream<List<ModuleModel>> getModules() {
    return db.collection('modules').orderBy('date').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ModuleModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Returns the auto-generated attendance code for sharing with students.
  Future<String> addModule(ModuleModel module) async {
    final code = _generateActivityCode();
    await db.collection('modules').add({...module.toMap(), 'code': code});
    return code;
  }

  Future<void> updateModule(ModuleModel module) async {
    await db.collection('modules').doc(module.id).update(module.toMap());
  }

  Future<void> deleteModule(String moduleId) async {
    await db.collection('modules').doc(moduleId).delete();
  }

  // ---------- ACTIVITY ATTENDANCE ----------

  // Returns:
  //   null              → code not found
  //   'already_checked_in' → student already recorded for this module
  //   module title      → success
  Future<String?> submitActivityAttendance({
    required String code,
    required String studentName,
    required String matricNumber,
    required String programme,
  }) async {
    final snap = await db
        .collection('modules')
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;

    final moduleData = snap.docs.first.data();
    final moduleName = moduleData['title'] ?? '';
    final moduleDate = moduleData['date'] ?? '';
    final checkInTime = _formatNow();

    final studentSnap = await db
        .collection('attendance')
        .where('matricNumber', isEqualTo: matricNumber)
        .limit(1)
        .get();

    if (studentSnap.docs.isNotEmpty) {
      final doc = studentSnap.docs.first;
      final records =
          List<Map<String, dynamic>>.from(doc.data()['records'] ?? []);
      if (records.any((r) => r['moduleName'] == moduleName)) {
        return 'already_checked_in';
      }
      records.add({
        'moduleName': moduleName,
        'date': moduleDate,
        'checkInTime': checkInTime,
        'isPresent': true,
      });
      await db.collection('attendance').doc(doc.id).update({
        'records': records,
        'totalRegistered': (doc.data()['totalRegistered'] ?? 0) + 1,
        'totalAttended': (doc.data()['totalAttended'] ?? 0) + 1,
      });
    } else {
      await db.collection('attendance').add({
        'studentName': studentName,
        'matricNumber': matricNumber,
        'programme': programme,
        'totalRegistered': 1,
        'totalAttended': 1,
        'records': [
          {
            'moduleName': moduleName,
            'date': moduleDate,
            'checkInTime': checkInTime,
            'isPresent': true,
          }
        ],
      });
    }
    return moduleName;
  }

  String _generateActivityCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _formatNow() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  // ---------- CLAIMS ----------

  Stream<List<ClaimModel>> getClaims() {
    return db.collection('claims').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ClaimModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Stream<int> getPendingClaimsCount() {
    return db
        .collection('claims')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> approveClaim(String claimId) async {
    await db.collection('claims').doc(claimId).update({'status': 'approved'});
  }

  Future<void> rejectClaim(String claimId, String reason) async {
    await db
        .collection('claims')
        .doc(claimId)
        .update({'status': 'rejected', 'rejectReason': reason});
  }

  // ---------- ATTENDANCE ----------

  Stream<List<StudentAttendance>> getAttendance() {
    return db.collection('attendance').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => StudentAttendance.fromMap(doc.id, doc.data()))
        .toList());
  }

  // ---------- DASHBOARD STATS ----------

  Future<Map<String, int>> getDashboardStats() async {
    final modulesSnap = await db.collection('modules').get();
    final approvedSnap = await db
        .collection('claims')
        .where('status', isEqualTo: 'approved')
        .get();
    final pendingSnap = await db
        .collection('claims')
        .where('status', isEqualTo: 'pending')
        .get();
    return {
      'activities': modulesSnap.docs.length,
      'approved': approvedSnap.docs.length,
      'pending': pendingSnap.docs.length,
    };
  }

  // ---------- SEED DATA ----------
  // Seeds the Kayak / 3D-Printing modules and a sample attendance record.
  // Claims are now seeded by FirebaseSeedService; this only touches modules.
  Future<void> seedSampleData() async {
    final existing = await db
        .collection('modules')
        .where('code', isEqualTo: 'KAYAK1')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    await db.collection('modules').add({
      'title': 'Kayak',
      'date': '5 April 2026',
      'startTime': '8:00 AM',
      'endTime': '4:00 PM',
      'lecturerId': 'LEC001',
      'lecturer': 'Prof. Sarah Wong',
      'venue': 'Pusat Rekreasi Air • PEKAN',
      'maxParticipants': 60,
      'registeredCount': 45,
      'code': 'KAYAK1',
    });
    await db.collection('modules').add({
      'title': '3D Printing',
      'date': '10 April 2026',
      'startTime': '8:00 AM',
      'endTime': '4:00 PM',
      'lecturerId': 'LEC002',
      'lecturer': 'Dr. Ahmad bin Ali',
      'venue': 'FKM-BK01 • PEKAN',
      'maxParticipants': 65,
      'registeredCount': 50,
      'code': 'PRINT1',
    });

    final attendanceExisting =
        await db.collection('attendance').limit(1).get();
    if (attendanceExisting.docs.isEmpty) {
      await db.collection('attendance').add({
        'studentName': 'Ahmad Imran',
        'matricNumber': 'CD210145',
        'programme': 'BCS',
        'totalRegistered': 1,
        'totalAttended': 1,
        'records': [
          {
            'moduleName': 'Kayak',
            'date': '5 April 2026',
            'checkInTime': '8:05 AM',
            'isPresent': true,
          }
        ],
      });
    }
  }

  // ---------- CLAIM MIGRATION ----------
  // Fixes claims seeded with wrong field types/names by FirebaseSeedService.
  // Runs once: skips any claim that already has a non-empty studentName.
  Future<void> migrateClaimsIfNeeded() async {
    const studentNames = {
      'A20CS1001': ('Ahmad Faiz bin Abdullah', 'A20CS1001'),
      'A20CS1002': ('Amalin Aisyah binti Aziz', 'A20CS1002'),
      'A20CS1003': ('Adani binti Mohd Fadzil', 'A20CS1003'),
    };

    final snap = await db.collection('claims').get();
    if (snap.docs.isEmpty) return;

    final batch = db.batch();
    bool dirty = false;

    for (final doc in snap.docs) {
      final data = doc.data();
      final name = (data['studentName'] as String?) ?? '';
      if (name.isNotEmpty) continue; // already migrated

      final studentId =
          (data['studentId'] ?? data['studentID'] ?? '') as String;
      final nameMatric = studentNames[studentId];

      final updates = <String, dynamic>{
        'studentName': nameMatric?.$1 ?? 'Unknown Student',
        'matricNumber': nameMatric?.$2 ?? studentId,
      };

      // Fix modules: String → List<String>
      final modulesRaw = data['modules'];
      if (modulesRaw is String) {
        updates['modules'] =
            modulesRaw.isNotEmpty ? [modulesRaw] : <String>[];
      }

      // Fix marks: int/double → String
      final marksRaw = data['marks'];
      if (marksRaw is! String) {
        updates['marks'] = '${marksRaw ?? 0}%';
      }

      // Fix submittedDate key capitalisation
      if (data['submittedDate'] == null && data['submitteddate'] != null) {
        updates['submittedDate'] = data['submitteddate'];
      }

      batch.update(doc.reference, updates);
      dirty = true;
    }

    if (dirty) await batch.commit();
  }
}