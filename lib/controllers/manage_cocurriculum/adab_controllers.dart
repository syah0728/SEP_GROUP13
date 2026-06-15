// controllers/manage_cocurriculum/adab_controllers.dart
// Business logic for Pusat Adab staff actions (claims, modules).
// Wraps FirebaseService so screens don't call Firestore directly.

import '../../services/firebase_services.dart';
import '../../models/manage_cocurriculum/claim.dart';
import '../../models/manage_cocurriculum/module.dart';

class AdabController {
  final FirebaseService _service = FirebaseService();

  // Returns a live stream of all claims
  Stream<List<ClaimModel>> getPendingClaims() => _service.getClaims();

  Future<bool> approveClaim(String claimId) async {
    try {
      await _service.approveClaim(claimId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectClaim(String claimId, String reason) async {
    try {
      await _service.rejectClaim(claimId, reason);
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<List<ModuleModel>> getModules() => _service.getModules();

  Future<bool> addModule(ModuleModel module) async {
    try {
      await _service.addModule(module);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteModule(String moduleId) async {
    try {
      await _service.deleteModule(moduleId);
      return true;
    } catch (_) {
      return false;
    }
  }
}