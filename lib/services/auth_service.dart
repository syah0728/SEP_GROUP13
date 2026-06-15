import 'package:cloud_firestore/cloud_firestore.dart';

/// Result of a successful login, with just enough identity info to populate
/// [AppSession] and route to the right shell.
class LoginResult {
  const LoginResult({
    required this.role,
    required this.id,
    required this.name,
    this.matricId,
  });

  final String role; // 'Student' | 'Lecturer' | 'Pusat Adab'
  final String id;
  final String name;
  final String? matricId;
}

/// Validates login credentials against Firestore.
///
/// - Student: looks up `students/{username}` (Student ID) or, if not found,
///   a student whose `matricId` matches the username. Checks `password`.
/// - Lecturer: looks up `lecturers/{username}` (Lecturer ID). Checks `password`.
/// - Pusat Adab: looks up `adabStaff` where `username` matches. Checks `password`.
class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<LoginResult?> login({
    required String role,
    required String username,
    required String password,
  }) async {
    switch (role) {
      case 'Student':
        return _loginStudent(username, password);
      case 'Lecturer':
        return _loginLecturer(username, password);
      case 'Pusat Adab':
        return _loginAdabStaff(username, password);
      case 'FK Staff':
        return _loginFKStaff(username, password);
      case 'Treasury':
        return _loginTreasury(username, password);
      default:
        return null;
    }
  }

  Future<LoginResult?> _loginStudent(String username, String password) async {
    Map<String, dynamic>? data;

    final byId = await _db.collection('students').doc(username).get();
    if (byId.exists) {
      data = byId.data();
    } else {
      final byMatric = await _db
          .collection('students')
          .where('matricId', isEqualTo: username)
          .limit(1)
          .get();
      if (byMatric.docs.isNotEmpty) {
        data = byMatric.docs.first.data();
      }
    }

    if (data == null || data['password'] != password) return null;

    return LoginResult(
      role: 'Student',
      id: (data['studentID'] ?? data['studentId']) as String,
      name: (data['studentName'] ?? data['name']) as String,
      matricId: (data['matricId'] ?? data['matricID']) as String?,
    );
  }

  Future<LoginResult?> _loginLecturer(String username, String password) async {
    final doc = await _db.collection('lecturers').doc(username).get();
    final data = doc.data();
    if (data == null || data['password'] != password) return null;

    return LoginResult(
      role: 'Lecturer',
      id: (data['lecturerID'] ?? doc.id) as String,
      name: (data['lecturer_name'] ?? 'Lecturer') as String,
    );
  }

  Future<LoginResult?> _loginAdabStaff(String username, String password) async {
    final snap = await _db
        .collection('adabStaff')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;

    final data = snap.docs.first.data();
    if (data['password'] != password) return null;

    return LoginResult(
      role: 'Pusat Adab',
      id: (data['adabID'] ?? snap.docs.first.id) as String,
      name: (data['staffName'] ?? 'Staff') as String,
    );
  }

  Future<LoginResult?> _loginFKStaff(String username, String password) async {
    final snap = await _db
        .collection('registrars')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;

    final data = snap.docs.first.data();
    if (data['password'] != password) return null;

    return LoginResult(
      role: 'FK Staff',
      id: (data['staffID'] ?? snap.docs.first.id) as String,
      name: (data['staff_name'] ?? 'FK Staff') as String,
    );
  }

  Future<LoginResult?> _loginTreasury(String username, String password) async {
    final snap = await _db
        .collection('treasury')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;

    final data = snap.docs.first.data();
    if (data['password'] != password) return null;

    return LoginResult(
      role: 'Treasury',
      id: (data['treasuryID'] ?? snap.docs.first.id) as String,
      name: (data['treasuryName'] ?? 'Treasury') as String,
    );
  }
}
