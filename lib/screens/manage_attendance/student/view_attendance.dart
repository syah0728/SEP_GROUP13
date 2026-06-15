import 'package:flutter/material.dart';

import '../../../controllers/manage_attendance/student_attendance_controller.dart';
import '../../../models/manage_attendance/student_models.dart';
import 'submit_attendance.dart';

// ── Student Attendance Record View (Subject List) ─────────────────────────────

class StudentAttendanceRecordView extends StatelessWidget {
  const StudentAttendanceRecordView({
    super.key,
    required this.controller,
    this.scaffoldKey,
    this.drawer,
  });
  final StudentAttendanceController controller;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return StudentPageScaffold(
      title: 'Attendance Record',
      onMenuTap: controller.backToDashboard,
      showBack: drawer == null,
      scaffoldKey: scaffoldKey,
      drawer: drawer,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.enrolledCourses.isEmpty
          ? const Center(
              child: Text(
                'No enrolled courses found.',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'My Subjects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.enrolledCourses.length} subjects enrolled',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 14),
                for (final course in controller.enrolledCourses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EnrolledCourseCard(
                      course: course,
                      onView: () => controller.openCourseAttendance(course),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EnrolledCourseCard extends StatelessWidget {
  const _EnrolledCourseCard({required this.course, required this.onView});

  final EnrolledCourse course;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF9B2EF4),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  course.courseCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B2EF4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course.lecturerName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B2EF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student Course Attendance Detail View ─────────────────────────────────────

class StudentCourseAttendanceView extends StatelessWidget {
  const StudentCourseAttendanceView({super.key, required this.controller});
  final StudentAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return StudentPageScaffold(
      title: 'Attendance Record',
      onMenuTap: controller.backToAttendanceRecord,
      showBack: true,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.selectedCourseAttendance == null
          ? const Center(
              child: Text(
                'No attendance data found.',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            )
          : _CourseAttendanceContent(
              summary: controller.selectedCourseAttendance!,
            ),
    );
  }
}

class _CourseAttendanceContent extends StatelessWidget {
  const _CourseAttendanceContent({required this.summary});
  final CourseAttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final badge = summary.badge;
    final badgeColor = badge == AttendanceBadge.good
        ? const Color(0xFF27AE60)
        : badge == AttendanceBadge.fair
        ? const Color(0xFFFF8A34)
        : const Color(0xFFFF4B66);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.course.courseName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.course.courseCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9B2EF4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.course.lecturerName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge.label,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      value: '${summary.attendanceRate.toStringAsFixed(0)}%',
                      label: 'Rate',
                      color: badgeColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatBox(
                      value: '${summary.totalPresent}',
                      label: 'Present',
                      color: const Color(0xFF27AE60),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatBox(
                      value: '${summary.totalAbsent}',
                      label: 'Absent',
                      color: const Color(0xFFFF4B66),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        if (summary.history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No attendance history yet.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              ),
            ),
          )
        else
          for (final entry in summary.history)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryTile(entry: entry),
            ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});
  final AttendanceHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final isPresent = entry.isPresent;
    final statusColor = isPresent
        ? const Color(0xFF27AE60)
        : const Color(0xFFFF4B66);
    final statusBg = isPresent
        ? const Color(0xFFE8FFF3)
        : const Color(0xFFFFEEF2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
            child: Icon(
              isPresent ? Icons.check_rounded : Icons.close_rounded,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.date,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.section} • ${entry.timeLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPresent ? 'Present' : 'Absent',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
