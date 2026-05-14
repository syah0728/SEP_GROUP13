import 'package:flutter/foundation.dart';

import '../../models/manage_attendance/attendance_models.dart';
import '../../services/attendance_service.dart';
import '../../services/gps_service.dart';

enum AttendanceScreen {
  dashboard,
  classes,
  classDetails,
  generateCode,
  generatedQr,
  attendanceRecordSelection,
  attendanceRecordList,
}

class AttendanceController extends ChangeNotifier {
  AttendanceController({
    required this.lecturerId,
    AttendanceService? service,
    GpsService? gpsService,
  }) : _service = service ?? FirebaseAttendanceService(),
       _gpsService = gpsService ?? GpsService();

  final String lecturerId;
  final AttendanceService _service;
  final GpsService _gpsService;

  LecturerProfile? lecturer;
  List<Course> courses = [];
  Course? selectedCourse;
  SessionOption? selectedSession;
  Course? selectedRecordCourse;
  SessionOption? selectedRecordSession;
  AttendanceSession? generatedSession;
  List<StudentAttendanceRecord> attendanceRecords = [];
  GpsValidationResult? gpsError;
  bool hasRecordUpdate = false;
  AttendanceScreen activeScreen = AttendanceScreen.dashboard;
  int selectedMenuIndex = 0;
  bool isLoading = true;
  String? errorMessage;

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      lecturer = await _service.fetchLecturerProfile(lecturerId);
      if (lecturer == null) {
        errorMessage = 'Lecturer ID not found. Please check your ID.';
        isLoading = false;
        notifyListeners();
        return;
      }
      courses = await _service.fetchAssignedCourses(lecturerId);
    } catch (e) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    isLoading = false;
    notifyListeners();
  }

  void selectMenu(int index) {
    selectedMenuIndex = index;
    if (index == 0) {
      activeScreen = AttendanceScreen.dashboard;
    } else if (index == 1) {
      activeScreen = AttendanceScreen.classes;
    } else if (index == 2) {
      activeScreen = AttendanceScreen.attendanceRecordSelection;
      selectedRecordCourse ??= _defaultRecordCourse();
      selectedRecordSession ??= selectedRecordCourse?.schedules.firstOrNull;
      hasRecordUpdate = false;
    }
    notifyListeners();
  }

  void openAttendanceManagement() => selectMenu(1);

  void openCourse(Course course) {
    selectedCourse = course;
    selectedSession = course.schedules.firstOrNull;
    generatedSession = null;
    gpsError = null;
    selectedMenuIndex = 1;
    activeScreen = AttendanceScreen.classDetails;
    notifyListeners();
  }

  void confirmSession(SessionOption session) {
    selectedSession = session;
    generatedSession = null;
    gpsError = null;
    selectedMenuIndex = 1;
    activeScreen = AttendanceScreen.generateCode;
    notifyListeners();
  }

  void backToClasses() {
    activeScreen = AttendanceScreen.classes;
    generatedSession = null;
    gpsError = null;
    notifyListeners();
  }

  void backToDetails() {
    activeScreen = AttendanceScreen.classDetails;
    generatedSession = null;
    gpsError = null;
    notifyListeners();
  }

  void setRecordSelection({
    required Course course,
    required SessionOption session,
  }) {
    selectedRecordCourse = course;
    selectedRecordSession = session;
    hasRecordUpdate = false;
    notifyListeners();
  }

  Future<void> openAttendanceRecords() async {
    final course = selectedRecordCourse ?? _defaultRecordCourse();
    final session = selectedRecordSession ?? course.schedules.first;

    selectedMenuIndex = 2;
    selectedRecordCourse = course;
    selectedRecordSession = session;
    isLoading = true;
    notifyListeners();

    try {
      attendanceRecords = await _service.fetchAttendanceRecords(
        course: course,
        session: session,
      );
    } catch (_) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    hasRecordUpdate = false;
    isLoading = false;
    activeScreen = AttendanceScreen.attendanceRecordList;
    notifyListeners();
  }

  Future<void> updateAttendanceStatus({
    required String recordId,
    required AttendanceStatus status,
  }) async {
    try {
      await _service.updateAttendanceRecord(recordId: recordId, status: status);
      attendanceRecords = attendanceRecords.map((r) {
        return r.recordId == recordId ? r.copyWith(status: status) : r;
      }).toList();
      hasRecordUpdate = true;
      notifyListeners();
    } catch (_) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
      notifyListeners();
    }
  }

  Future<void> generateAttendanceCode() async {
    final course = selectedCourse;
    final session = selectedSession;
    if (course == null || session == null) return;

    isLoading = true;
    gpsError = null;
    notifyListeners();

    final validation = await _gpsService.verifyLecturerLocation(
      requiredLatitude: session.location.latitude,
      requiredLongitude: session.location.longitude,
      maxDistanceMeters: 150,
    );

    if (!validation.isAllowed) {
      // A1: GPS Not Detected — redirect Lecturer to Class Details page
      gpsError = validation;
      isLoading = false;
      activeScreen = AttendanceScreen.classDetails;
      notifyListeners();
      return;
    }

    try {
      generatedSession = await _service.createAttendanceSession(
        course: course,
        session: session,
        lecturerId: lecturerId,
      );
      activeScreen = AttendanceScreen.generatedQr;
    } catch (_) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    isLoading = false;
    notifyListeners();
  }

  Course _defaultRecordCourse() {
    return courses.firstWhere(
      (c) => c.courseCode == 'BCS1023',
      orElse: () => courses.first,
    );
  }
}
