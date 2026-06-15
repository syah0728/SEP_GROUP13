import 'dart:async';

import 'package:flutter/foundation.dart';
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
    const locationServicesHint =
        'Please make sure Location/GPS is turned on for this device and '
        'browser, then try again.';

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (
          isAllowed: false,
          message: 'Location services are turned off. $locationServicesHint',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (
          isAllowed: false,
          message: 'Location permission was not granted. $locationServicesHint',
        );
      }

      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException('GPS timeout'),
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
              'You are not within the allowed classroom area '
              '(${distance.toStringAsFixed(0)}m away, max ${maxDistanceMeters.toStringAsFixed(0)}m). '
              'Your location: ${position.latitude.toStringAsFixed(6)}, '
              '${position.longitude.toStringAsFixed(6)}. '
              'Required: ${requiredLatitude.toStringAsFixed(6)}, '
              '${requiredLongitude.toStringAsFixed(6)}. '
              'Please go to the classroom.',
        );
      }

      return (isAllowed: true, message: 'GPS verified.');
    } on TimeoutException catch (e) {
      debugPrint('GpsService: timed out getting location: $e');
      return (
        isAllowed: false,
        message: 'Could not get your location in time. $locationServicesHint',
      );
    } on LocationServiceDisabledException catch (e) {
      debugPrint('GpsService: location service disabled: $e');
      return (
        isAllowed: false,
        message: 'Location services are turned off. $locationServicesHint',
      );
    } on PermissionDeniedException catch (e) {
      debugPrint('GpsService: permission denied: $e');
      return (
        isAllowed: false,
        message: 'Location permission was not granted. $locationServicesHint',
      );
    } catch (e) {
      debugPrint('GpsService: failed to get location: $e');
      return (
        isAllowed: false,
        message: 'Failed to get location. $locationServicesHint',
      );
    }
  }
}
