// controllers/manage_cocurriculum/student_controllers.dart
// Business logic for student actions (view modules, submit claims).
// Wraps FirebaseService so screens don't call Firestore directly.

import '../../services/firebase_services.dart';
import '../../models/manage_cocurriculum/module.dart';
import '../../models/manage_cocurriculum/claim.dart';

class StudentController {
  final FirebaseService _service = FirebaseService();

  // Returns available co-curriculum modules as a live stream
  Stream<List<ModuleModel>> getModules() => _service.getModules();

  // Returns claims for the current student (filtered by matricNumber)
  Stream<List<ClaimModel>> getMyClaims(String matricNumber) {
    return _service.getClaims().map(
        (list) => list.where((c) => c.matricNumber == matricNumber).toList());
  }

  // Returns total approved CATS points for a student
  Stream<int> getTotalCats(String matricNumber) {
    return getMyClaims(matricNumber).map((claims) => claims
        .where((c) => c.status == 'approved')
        .length * 2); // each approved claim = 2 CATS
  }
}