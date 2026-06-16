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

  // Returns the attendance code. Uses moduleId as the Firestore document ID
  // so all module docs are consistently named MOD001, MOD002, etc.
  Future<String> addModule(ModuleModel module) async {
    final code = _generateActivityCode();
    final moduleId = await _generateNextModuleId();
    await db.collection('modules').doc(moduleId).set({
      ...module.toMap(),
      'moduleId': moduleId,
      'code': code,
    });
    return code;
  }

  // Finds the highest existing MOD number and returns the next one.
  Future<String> _generateNextModuleId() async {
    final snap = await db.collection('modules').get();
    int maxNum = 0;
    for (final doc in snap.docs) {
      final id = doc.id;
      if (id.startsWith('MOD')) {
        final n = int.tryParse(id.substring(3)) ?? 0;
        if (n > maxNum) maxNum = n;
      }
    }
    return 'MOD${(maxNum + 1).toString().padLeft(3, '0')}';
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

  // Returns full attended records [{moduleName, date, checkInTime}] for a student (isPresent=true).
  Future<List<Map<String, dynamic>>> getAttendedModuleRecords(String matricNumber) async {
    final snap = await db
        .collection('attendance')
        .where('matricNumber', isEqualTo: matricNumber)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return [];
    final records = List<Map<String, dynamic>>.from(
        snap.docs.first.data()['records'] ?? []);
    return records
        .where((r) => r['isPresent'] == true)
        .map<Map<String, dynamic>>((r) => {
              'moduleName': r['moduleName'] as String,
              'date': r['date'] as String,
              'checkInTime': (r['checkInTime'] as String?) ?? '',
            })
        .toList();
  }

  // Returns the set of module titles the student has attended (isPresent=true).
  Future<Set<String>> getAttendedModuleNames(String matricNumber) async {
    final snap = await db
        .collection('attendance')
        .where('matricNumber', isEqualTo: matricNumber)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return {};
    final records = List<Map<String, dynamic>>.from(
        snap.docs.first.data()['records'] ?? []);
    return records
        .where((r) => r['isPresent'] == true)
        .map<String>((r) => r['moduleName'] as String)
        .toSet();
  }

  // ---------- REGISTRATIONS ----------

  Future<void> registerForModule({
    required String matricNumber,
    required String studentName,
    required String moduleName,
    required String moduleDate,
  }) async {
    final snap = await db
        .collection('registrations')
        .where('matricNumber', isEqualTo: matricNumber)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      final modules =
          List<Map<String, dynamic>>.from(doc.data()['modules'] ?? []);
      if (modules.any((m) => m['moduleName'] == moduleName)) return;
      modules.add({
        'moduleName': moduleName,
        'date': moduleDate,
        'registeredAt': DateTime.now().toIso8601String(),
      });
      await db
          .collection('registrations')
          .doc(doc.id)
          .update({'modules': modules});
    } else {
      await db.collection('registrations').add({
        'matricNumber': matricNumber,
        'studentName': studentName,
        'modules': [
          {
            'moduleName': moduleName,
            'date': moduleDate,
            'registeredAt': DateTime.now().toIso8601String(),
          }
        ],
      });
    }
  }

  Future<Set<String>> getRegisteredModuleNames(String matricNumber) async {
    final snap = await db
        .collection('registrations')
        .where('matricNumber', isEqualTo: matricNumber)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return {};
    final modules = List<Map<String, dynamic>>.from(
        snap.docs.first.data()['modules'] ?? []);
    return modules.map<String>((m) => m['moduleName'] as String).toSet();
  }

  Future<List<Map<String, dynamic>>> getRegisteredModuleRecords(
      String matricNumber) async {
    final snap = await db
        .collection('registrations')
        .where('matricNumber', isEqualTo: matricNumber)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return [];
    final modules = List<Map<String, dynamic>>.from(
        snap.docs.first.data()['modules'] ?? []);
    return modules
        .map<Map<String, dynamic>>((m) => {
              'moduleName': m['moduleName'] as String,
              'date': m['date'] as String,
            })
        .toList();
  }

  // ---------- SEED DATA ----------
  // Seeds the Kayak / 3D-Printing modules and a sample attendance record.
  // Claims are now seeded by FirebaseSeedService; this only touches modules.
  Future<void> seedSampleData() async {
    // Guard: skip if MOD001 already exists as a document
    final existing = await db.collection('modules').doc('MOD001').get();
    if (existing.exists) return;

    await db.collection('modules').doc('MOD001').set({
      'moduleId': 'MOD001',
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
    await db.collection('modules').doc('MOD002').set({
      'moduleId': 'MOD002',
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

  // ---------- MODULE ID MIGRATION ----------
  // 1. Moves any docs with random Firestore auto-IDs to MOD001-style doc IDs.
  // 2. Backfills missing moduleId, code, and lecturer fields on all MOD___ docs.
  // Safe to call on every app start.
  Future<void> migrateModuleIdsIfNeeded() async {
    final snap = await db.collection('modules').get();

    // Step 1: move random-ID docs to MOD___ IDs
    final randomDocs = snap.docs.where((d) => !d.id.startsWith('MOD')).toList();
    int maxNum = 0;
    for (final doc in snap.docs) {
      if (doc.id.startsWith('MOD')) {
        final n = int.tryParse(doc.id.substring(3)) ?? 0;
        if (n > maxNum) maxNum = n;
      }
    }
    if (randomDocs.isNotEmpty) {
      final batch = db.batch();
      int counter = maxNum + 1;
      for (final oldDoc in randomDocs) {
        final newId = 'MOD${counter.toString().padLeft(3, '0')}';
        batch.set(db.collection('modules').doc(newId),
            {...oldDoc.data(), 'moduleId': newId});
        batch.delete(oldDoc.reference);
        counter++;
      }
      await batch.commit();
    }

    // Step 2: backfill moduleId (lowercase), code, and lecturer on MOD___ docs
    final allSnap = await db.collection('modules').get();
    final batch2 = db.batch();
    bool dirty = false;
    for (final doc in allSnap.docs) {
      if (!doc.id.startsWith('MOD')) continue;
      final data = doc.data();
      final updates = <String, dynamic>{};

      if (((data['moduleId'] as String?) ?? '').isEmpty) {
        updates['moduleId'] = doc.id;
      }
      if (((data['code'] as String?) ?? '').isEmpty) {
        updates['code'] = _generateActivityCode();
      }
      if (((data['lecturer'] as String?) ?? '').isEmpty) {
        updates['lecturer'] = 'Assigned Lecturer';
      }

      if (updates.isNotEmpty) {
        batch2.update(doc.reference, updates);
        dirty = true;
      }
    }
    if (dirty) await batch2.commit();
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