import 'package:geolocator/geolocator.dart';

import '../models/manage_attendance/attendance_models.dart';
import '../models/manage_attendance/student_models.dart';

class GpsService {
  Future<GpsValidationResult> verifyLecturerLocation({
    required double requiredLatitude,
    required double requiredLongitude,
    required double maxDistanceMeters,
  }) async {
    final result = await _getAndValidatePosition(
      requiredLatitude: requiredLatitude,
      requiredLongitude: requiredLongitude,
      maxDistanceMeters: maxDistanceMeters,
    );
    return GpsValidationResult(
      isAllowed: result.isAllowed,
      message: result.message,
    );
  }

  Future<StudentLocationResult> verifyStudentLocation({
    required double requiredLatitude,
    required double requiredLongitude,
    required double maxDistanceMeters,
  }) async {
    final result = await _getAndValidatePosition(
      requiredLatitude: requiredLatitude,
      requiredLongitude: requiredLongitude,
      maxDistanceMeters: maxDistanceMeters,
    );
    return StudentLocationResult(
      isAllowed: result.isAllowed,
      message: result.message,
    );
  }

  Future<({bool isAllowed, String message})> _getAndValidatePosition({
    required double requiredLatitude,
    required double requiredLongitude,
    required double maxDistanceMeters,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (
          isAllowed: false,
          message: 'Location access denied. Please enable GPS.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (
            isAllowed: false,
            message: 'Location access denied. Please enable GPS.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return (
          isAllowed: false,
          message:
              'Location access permanently denied. Please enable in device settings.',
        );
      }

      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('GPS timeout'),
          );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        requiredLatitude,
        requiredLongitude,
      );

      if (distance > maxDistanceMeters) {
        return (
          isAllowed: false,
          message:
              'You are not within the allowed classroom area. Please go to the classroom.',
        );
      }

      return (isAllowed: true, message: 'GPS verified.');
    } catch (_) {
      return (
        isAllowed: false,
        message: 'Failed to get location. Please try again.',
      );
    }
  }
}
