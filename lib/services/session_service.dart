/// Holds the identity of whoever is currently logged in, so the rest of the
/// app (dashboards, attendance pages, sidebars) can show that person's own
/// data instead of a fixed demo identity.
///
/// Falls back to the original demo identities when nobody has logged in yet,
/// so direct links used for testing keep working.
class AppSession {
  AppSession._();

  static String? _studentId;
  static String? _studentName;
  static String? _matricId;

  static String? _lecturerId;
  static String? _lecturerName;

  static String? _adabId;
  static String? _adabName;

  static String? _fkStaffId;
  static String? _fkStaffName;

  static String? _treasuryId;
  static String? _treasuryName;

  static String get studentId => _studentId ?? 'A20CS1004';
  static String get studentName => _studentName ?? 'Ahmad Imran';
  static String get matricId => _matricId ?? 'CD210145';

  static String get lecturerId => _lecturerId ?? 'LE210145';
  static String get lecturerName => _lecturerName ?? 'Dr. Hafiz bin Abdullah';

  static String get adabId => _adabId ?? 'ADAB001';
  static String get adabName => _adabName ?? 'Nurul Aisyah';

  static String get fkStaffId => _fkStaffId ?? 'REG001';
  static String get fkStaffName => _fkStaffName ?? 'FK Staff';

  static String get treasuryId => _treasuryId ?? 'TRES001';
  static String get treasuryName => _treasuryName ?? 'Treasury';

  static void setStudent({
    required String studentId,
    required String studentName,
    required String matricId,
  }) {
    _studentId = studentId;
    _studentName = studentName;
    _matricId = matricId;
  }

  static void setLecturer({required String lecturerId, String? lecturerName}) {
    _lecturerId = lecturerId;
    _lecturerName = lecturerName;
  }

  static void setAdab({required String adabId, required String adabName}) {
    _adabId = adabId;
    _adabName = adabName;
  }

  static void setFKStaff({required String fkStaffId, required String fkStaffName}) {
    _fkStaffId = fkStaffId;
    _fkStaffName = fkStaffName;
  }

  static void setTreasury({required String treasuryId, required String treasuryName}) {
    _treasuryId = treasuryId;
    _treasuryName = treasuryName;
  }

  static void clear() {
    _studentId = null;
    _studentName = null;
    _matricId = null;
    _lecturerId = null;
    _lecturerName = null;
    _adabId = null;
    _adabName = null;
    _fkStaffId = null;
    _fkStaffName = null;
    _treasuryId = null;
    _treasuryName = null;
  }
}
