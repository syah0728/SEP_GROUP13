// lib/models/module_model.dart
// This file defines what a "Module" looks like in our app.
// A Module is a co-curriculum activity like Kayak, 3D Printing, etc.
// This matches the Firestore 'modules' collection.

class ModuleModel {
  final String id;             // Firestore document ID (= moduleID PK)
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String lecturerId;     // FK → Lecturer.lecturerID
  final String lecturer;       // denormalized lecturer name for display
  final String venue;
  final int maxParticipants;
  final int registeredCount;
  final String code;           // 6-char attendance code shared with students

  ModuleModel({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.lecturerId = '',
    required this.lecturer,
    required this.venue,
    required this.maxParticipants,
    required this.registeredCount,
    this.code = '',
  });

  factory ModuleModel.fromMap(String id, Map<String, dynamic> data) {
    return ModuleModel(
      id: id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '8:00 AM',
      endTime: data['endTime'] ?? '4:00 PM',
      lecturerId: data['lecturerId'] ?? '',
      lecturer: data['lecturer'] ?? '',
      venue: data['venue'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 50,
      registeredCount: data['registeredCount'] ?? 0,
      code: data['code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'lecturerId': lecturerId,
      'lecturer': lecturer,
      'venue': venue,
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
      'code': code,
    };
  }
}
