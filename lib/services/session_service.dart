import 'package:shared_preferences/shared_preferences.dart';

/// Holds the identity of whoever is currently logged in, so the rest of the
/// app (dashboards, attendance pages, sidebars) can show that person's own
/// data instead of a fixed demo identity.
///
/// The session is mirrored to local storage so it survives a page reload
/// (e.g. browser back/forward on Flutter Web), and is restored on startup
/// via [restore]. Falls back to the original demo identities when nobody
/// has logged in yet, so direct links used for testing keep working.
class AppSession {
  AppSession._();

  static const _keyRole = 'session_role';
  static const _keyStudentId = 'session_student_id';
  static const _keyStudentName = 'session_student_name';
  static const _keyMatricId = 'session_matric_id';
  static const _keyLecturerId = 'session_lecturer_id';
  static const _keyLecturerName = 'session_lecturer_name';
  static const _keyAdabId = 'session_adab_id';
  static const _keyAdabName = 'session_adab_name';

  static String? _role;

  static String? _studentId;
  static String? _studentName;
  static String? _matricId;

  static String? _lecturerId;
  static String? _lecturerName;

  static String? _adabId;
  static String? _adabName;

  static String? get role => _role;

  static String get studentId => _studentId ?? 'A20CS1004';
  static String get studentName => _studentName ?? 'Ahmad Imran';
  static String get matricId => _matricId ?? 'CD210145';

  static String get lecturerId => _lecturerId ?? 'LE210145';
  static String get lecturerName => _lecturerName ?? 'Dr. Hafiz bin Abdullah';

  static String get adabId => _adabId ?? 'ADAB001';
  static String get adabName => _adabName ?? 'Nurul Aisyah';

  /// Reloads the session from local storage. Call this once on app startup,
  /// before [runApp], so a page reload doesn't lose the logged-in identity.
  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString(_keyRole);
    _studentId = prefs.getString(_keyStudentId);
    _studentName = prefs.getString(_keyStudentName);
    _matricId = prefs.getString(_keyMatricId);
    _lecturerId = prefs.getString(_keyLecturerId);
    _lecturerName = prefs.getString(_keyLecturerName);
    _adabId = prefs.getString(_keyAdabId);
    _adabName = prefs.getString(_keyAdabName);
  }

  static Future<void> setStudent({
    required String studentId,
    required String studentName,
    required String matricId,
  }) async {
    _role = 'Student';
    _studentId = studentId;
    _studentName = studentName;
    _matricId = matricId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, _role!);
    await prefs.setString(_keyStudentId, studentId);
    await prefs.setString(_keyStudentName, studentName);
    await prefs.setString(_keyMatricId, matricId);
  }

  static Future<void> setLecturer({
    required String lecturerId,
    String? lecturerName,
  }) async {
    _role = 'Lecturer';
    _lecturerId = lecturerId;
    _lecturerName = lecturerName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, _role!);
    await prefs.setString(_keyLecturerId, lecturerId);
    if (lecturerName != null) {
      await prefs.setString(_keyLecturerName, lecturerName);
    } else {
      await prefs.remove(_keyLecturerName);
    }
  }

  static Future<void> setAdab({
    required String adabId,
    required String adabName,
  }) async {
    _role = 'Pusat Adab';
    _adabId = adabId;
    _adabName = adabName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, _role!);
    await prefs.setString(_keyAdabId, adabId);
    await prefs.setString(_keyAdabName, adabName);
  }

  static Future<void> clear() async {
    _role = null;
    _studentId = null;
    _studentName = null;
    _matricId = null;
    _lecturerId = null;
    _lecturerName = null;
    _adabId = null;
    _adabName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRole);
    await prefs.remove(_keyStudentId);
    await prefs.remove(_keyStudentName);
    await prefs.remove(_keyMatricId);
    await prefs.remove(_keyLecturerId);
    await prefs.remove(_keyLecturerName);
    await prefs.remove(_keyAdabId);
    await prefs.remove(_keyAdabName);
  }
}
