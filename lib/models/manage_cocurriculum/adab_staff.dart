// models/manage_cocurriculum/adab_staff.dart
// Represents a Pusat Adab staff member.
// Temporary — will connect with the authentication module later.

class AdabStaffModel {
  final String id;        // Firestore document ID (= adabID PK)
  final String staffName; // = staffName in data dictionary
  final String username;  // unique login username
  final String email;
  final String staffId;   // e.g. "ADAB001"
  final String role;      // e.g. "Pusat Adab Staff"

  AdabStaffModel({
    required this.id,
    required this.staffName,
    this.username = '',
    required this.email,
    this.staffId = '',
    this.role = 'Pusat Adab Staff',
  });

  factory AdabStaffModel.fromMap(String id, Map<String, dynamic> data) {
    return AdabStaffModel(
      id: id,
      staffName: data['staffName'] ?? data['fullName'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      staffId: data['staffId'] ?? '',
      role: data['role'] ?? 'Pusat Adab Staff',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffName': staffName,
      'username': username,
      'email': email,
      'staffId': staffId,
      'role': role,
    };
  }
}