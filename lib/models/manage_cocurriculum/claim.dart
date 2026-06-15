// lib/models/claim_model.dart
// This file defines what a "Claim" looks like.
// A Claim is when a student submits their co-curriculum hours for approval.
// Status can be: 'pending', 'approved', or 'rejected'

class ClaimModel {
  final String id;            // Firestore document ID (= claimID PK)
  final String studentId;     // FK → Student.studentID
  final String studentName;   // denormalized for display
  final String matricNumber;  // denormalized for display
  final String moduleId;      // FK → Module.moduleID
  final String adabId;        // FK → Adab_Staff.adabID (staff who processed)
  final String submittedDate;
  final String status;        // 'pending', 'approved', 'rejected'
  final List<String> modules; // module names (denormalized for display)
  final String marks;
  final String grade;
  final String rejectReason;

  ClaimModel({
    required this.id,
    this.studentId = '',
    required this.studentName,
    required this.matricNumber,
    this.moduleId = '',
    this.adabId = '',
    required this.submittedDate,
    required this.status,
    required this.modules,
    required this.marks,
    required this.grade,
    this.rejectReason = '',
  });

  factory ClaimModel.fromMap(String id, Map<String, dynamic> data) {
    // modules can be a List (correct) or a String (old seed format)
    final modulesRaw = data['modules'];
    final List<String> modulesList;
    if (modulesRaw is List) {
      modulesList = List<String>.from(modulesRaw);
    } else if (modulesRaw is String && modulesRaw.isNotEmpty) {
      modulesList = [modulesRaw];
    } else {
      modulesList = [];
    }

    // marks can be a String (correct) or a number (old seed format)
    final marksRaw = data['marks'];
    final String marksStr = marksRaw is String
        ? marksRaw
        : marksRaw != null
            ? '$marksRaw%'
            : '0%';

    return ClaimModel(
      id: id,
      // handle both 'studentId' and 'studentID' capitalisations
      studentId: data['studentId'] ?? data['studentID'] ?? '',
      studentName: data['studentName'] ?? '',
      matricNumber: data['matricNumber'] ?? '',
      moduleId: data['moduleId'] ?? data['moduleID'] ?? '',
      adabId: data['adabId'] ?? data['adabID'] ?? '',
      // handle 'submittedDate' (correct) and 'submitteddate' (old seed)
      submittedDate: data['submittedDate'] ?? data['submitteddate'] ?? '',
      status: data['status'] ?? 'pending',
      modules: modulesList,
      marks: marksStr,
      grade: data['grade'] ?? 'N/A',
      rejectReason: data['rejectReason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'matricNumber': matricNumber,
      'moduleId': moduleId,
      'adabId': adabId,
      'submittedDate': submittedDate,
      'status': status,
      'modules': modules,
      'marks': marks,
      'grade': grade,
      'rejectReason': rejectReason,
    };
  }
}
