import 'package:flutter/foundation.dart';

import '../../models/manage_attendance/student_models.dart';
import '../../services/gps_service.dart';
import '../../services/student_attendance_service.dart';

enum StudentScreen {
  dashboard,
  submitAttendance,
  classDetails,
  attendanceRecord,
  courseAttendance,
}

enum AttendanceInputMethod { qrScan, manualCode }

class StudentAttendanceController extends ChangeNotifier {
  StudentAttendanceController({
    required this.studentId,
    StudentAttendanceService? service,
    GpsService? gpsService,
  }) : _service = service ?? FirebaseStudentAttendanceService(),
       _gpsService = gpsService ?? GpsService();

  final String studentId;
  final StudentAttendanceService _service;
  final GpsService _gpsService;

  StudentProfile? student;
  StudentClassDetails? classDetails;
  StudentAttendanceSubmission? submission;
  List<EnrolledCourse> enrolledCourses = [];
  CourseAttendanceSummary? selectedCourseAttendance;

  StudentScreen activeScreen = StudentScreen.dashboard;
  AttendanceInputMethod inputMethod = AttendanceInputMethod.qrScan;
  bool isLoading = true;
  bool isSubmitting = false;
  bool showInvalidCode = false;
  bool showGpsError = false;
  bool showSuccess = false;
  bool showAlreadySubmitted = false;
  String attendanceCode = '';
  String gpsMessage = '';
  String? errorMessage;

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      student = await _service.fetchStudentProfile(studentId);
      if (student == null) {
        errorMessage = 'Student ID not found. Please check your ID.';
      }
    } catch (_) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    isLoading = false;
    notifyListeners();
  }

  void openSubmitAttendance() {
    activeScreen = StudentScreen.submitAttendance;
    inputMethod = AttendanceInputMethod.qrScan;
    attendanceCode = '';
    classDetails = null;
    submission = null;
    showInvalidCode = false;
    showGpsError = false;
    showSuccess = false;
    showAlreadySubmitted = false;
    notifyListeners();
  }

  void backToDashboard() {
    activeScreen = StudentScreen.dashboard;
    notifyListeners();
  }

  void setInputMethod(AttendanceInputMethod method) {
    inputMethod = method;
    showInvalidCode = false;
    showGpsError = false;
    attendanceCode = '';
    notifyListeners();
  }

  void updateAttendanceCode(String value) {
    attendanceCode = value;
    if (showInvalidCode) showInvalidCode = false;
    notifyListeners();
  }

  Future<void> onQrCodeScanned(String scannedCode) async {
    attendanceCode = scannedCode;
    await verifyAttendanceCode();
  }

  Future<void> verifyAttendanceCode() async {
    final code = inputMethod == AttendanceInputMethod.qrScan
        ? attendanceCode
        : attendanceCode;

    if (code.trim().isEmpty) {
      showInvalidCode = true;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final details = await _service.verifyAttendanceCode(code);
      isLoading = false;

      if (details == null) {
        showInvalidCode = true;
        classDetails = null;
        notifyListeners();
        return;
      }

      classDetails = details;
      showInvalidCode = false;
      showGpsError = false;
      showSuccess = false;
      activeScreen = StudentScreen.classDetails;
    } catch (_) {
      isLoading = false;
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    notifyListeners();
  }

  Future<void> confirmAttendance() async {
    final details = classDetails;
    final profile = student;
    if (details == null || profile == null) return;

    isSubmitting = true;
    showGpsError = false;
    notifyListeners();

    final gpsResult = await _gpsService.verifyStudentLocation(
      requiredLatitude: details.latitude,
      requiredLongitude: details.longitude,
      maxDistanceMeters: 150,
    );

    if (!gpsResult.isAllowed) {
      gpsMessage = gpsResult.message;
      showGpsError = true;
      showSuccess = false;
      isSubmitting = false;
      activeScreen = StudentScreen.submitAttendance;
      notifyListeners();
      return;
    }

    try {
      submission = await _service.submitAttendance(
        studentId: profile.studentId,
        matricId: profile.matricId,
        studentName: profile.name,
        classDetails: details,
      );
      showSuccess = true;
      showGpsError = false;
      showAlreadySubmitted = false;
    } on AlreadySubmittedException {
      // Rule: Students can submit attendance only once per session
      showAlreadySubmitted = true;
      showSuccess = false;
    } catch (_) {
      // E1: Internet Connection Failure
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    isSubmitting = false;
    notifyListeners();
  }

  void retryInvalidCode() {
    showInvalidCode = false;
    attendanceCode = '';
    notifyListeners();
  }

  void retryGps() {
    showGpsError = false;
    notifyListeners();
  }

  // ── Attendance Record ──────────────────────────────────────────────

  Future<void> openAttendanceRecord() async {
    activeScreen = StudentScreen.attendanceRecord;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      enrolledCourses = await _service.fetchEnrolledCourses(studentId);
    } catch (_) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    isLoading = false;
    notifyListeners();
  }

  void backToAttendanceRecord() {
    activeScreen = StudentScreen.attendanceRecord;
    selectedCourseAttendance = null;
    notifyListeners();
  }

  Future<void> openCourseAttendance(EnrolledCourse course) async {
    activeScreen = StudentScreen.courseAttendance;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedCourseAttendance = await _service.fetchCourseAttendance(
        studentId: studentId,
        course: course,
      );
    } catch (_) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }

    isLoading = false;
    notifyListeners();
  }
}
