enum AttendanceStatus { present, absent }

enum AttendanceBadge { good, fair, poor }

extension AttendanceBadgeExt on AttendanceBadge {
  String get label => switch (this) {
    AttendanceBadge.good => 'Good',
    AttendanceBadge.fair => 'Fair',
    AttendanceBadge.poor => 'Poor',
  };
}
