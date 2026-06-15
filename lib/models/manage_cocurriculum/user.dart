class UserModel {
  final int? id;
  final String matricNumber;
  final String fullName;
  final String email;
  final String userType;
  final String createdAt;

  UserModel({
    this.id,
    required this.matricNumber,
    required this.fullName,
    required this.email,
    required this.userType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matric_number': matricNumber,
      'full_name': fullName,
      'email': email,
      'user_type': userType,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      matricNumber: map['matric_number'],
      fullName: map['full_name'],
      email: map['email'],
      userType: map['user_type'],
      createdAt: map['created_at'],
    );
  }
}
