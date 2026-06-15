import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../controllers/manage_attendance/attendance_controller.dart';
import '../../../models/manage_attendance/attendance_models.dart';
import '../../../services/session_service.dart';

// ── Shared App Scaffold ───────────────────────────────────────────────────────

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3D8EF5), Color(0xFF2F80ED)],
            ),
          ),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5F5F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showCurriculum = false,
  });

  final Course course;
  final VoidCallback onTap;
  final bool showCurriculum;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF2F80ED),
                size: 22,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    course.courseCode,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                  if (showCurriculum) ...[
                    const SizedBox(height: 3),
                    Text(
                      course.curriculum,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B51E0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${course.enrolledCount} students',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF2F80ED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseHeading extends StatelessWidget {
  const CourseHeading({super.key, required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.courseName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          course.courseCode,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2F80ED),
          ),
        ),
      ],
    );
  }
}

class GpsErrorCard extends StatelessWidget {
  const GpsErrorCard({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4B66)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFFFEEF2),
            child: Icon(
              Icons.location_off_rounded,
              color: Color(0xFFFF4B66),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPS Location Error',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF4B66),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF4B66),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoStripe extends StatelessWidget {
  const InfoStripe({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111827),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class DropdownField<T> extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6B7280),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(itemLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class LecturerDrawer extends StatelessWidget {
  const LecturerDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSwitchActor,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onSwitchActor;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3D8EF5), Color(0xFF2F80ED)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppSession.lecturerName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            AppSession.lecturerId,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Lecturer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  DrawerItem(
                    icon: Icons.space_dashboard_outlined,
                    label: 'Dashboard',
                    selected: selectedIndex == 0,
                    onTap: () => onSelect(0),
                  ),
                  DrawerItem(
                    icon: Icons.qr_code_2_rounded,
                    label: 'Attendance Management',
                    selected: selectedIndex == 1,
                    onTap: () => onSelect(1),
                  ),
                  DrawerItem(
                    icon: Icons.assignment_outlined,
                    label: 'Attendance Record',
                    selected: selectedIndex == 2,
                    onTap: () => onSelect(2),
                  ),
                  const Spacer(),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onSwitchActor,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Color(0xFFFF4B66),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Color(0xFFFF4B66),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? const Color(0xFF2F80ED)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard View ────────────────────────────────────────────────────────────

class AttendanceDashboardView extends StatelessWidget {
  const AttendanceDashboardView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final lecturer = controller.lecturer!;
    return AppScaffold(
      title: 'Lecturer Dashboard',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5A9DF8), Color(0xFF2F80ED)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lecturer.title,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lecturer.lecturerId,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  lecturer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lecturer.semesterLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Courses',
                  value: '${controller.courses.length}',
                  subtitle: 'This Semester',
                  color: const Color(0xFF7C5CFC),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _MetricCard(
                  icon: Icons.groups_2_outlined,
                  title: 'Students',
                  value: '187',
                  subtitle: 'Across all courses',
                  color: Color(0xFF27AE60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Classes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.openAttendanceManagement,
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: Color(0xFF2F80ED),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final course in controller.courses)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(
                course: course,
                onTap: () => controller.openCourse(course),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ── Classes View ──────────────────────────────────────────────────────────────

class AttendanceClassesView extends StatelessWidget {
  const AttendanceClassesView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Attendance Management',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'My Classes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (final course in controller.courses)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: CourseCard(
                course: course,
                showCurriculum: true,
                onTap: () => controller.openCourse(course),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Class Details View ────────────────────────────────────────────────────────

class AttendanceClassDetailsView extends StatefulWidget {
  const AttendanceClassDetailsView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  State<AttendanceClassDetailsView> createState() =>
      _AttendanceClassDetailsViewState();
}

class _AttendanceClassDetailsViewState
    extends State<AttendanceClassDetailsView> {
  late String selectedSection;
  late String selectedDate;
  late String selectedTime;

  @override
  void initState() {
    super.initState();
    final s = widget.controller.selectedSession!;
    selectedSection = s.section;
    selectedDate = s.date;
    selectedTime = s.timeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.controller.selectedCourse!;
    final sectionOptions = course.schedules
        .map((e) => e.section)
        .toSet()
        .toList();
    final dateOptions = course.schedules
        .where((s) => s.section == selectedSection)
        .map((s) => s.date)
        .toSet()
        .toList();
    final timeOptions = course.schedules
        .where((s) => s.section == selectedSection && s.date == selectedDate)
        .map((s) => s.timeLabel)
        .toList();

    if (!dateOptions.contains(selectedDate)) selectedDate = dateOptions.first;
    if (!timeOptions.contains(selectedTime)) selectedTime = timeOptions.first;

    final selectedSession = course.schedules.firstWhere(
      (s) =>
          s.section == selectedSection &&
          s.date == selectedDate &&
          s.timeLabel == selectedTime,
    );

    return AppScaffold(
      title: 'Class Details',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.controller.gpsError != null) ...[
            GpsErrorCard(message: widget.controller.gpsError!.message),
            const SizedBox(height: 16),
          ],
          CourseHeading(course: course),
          const SizedBox(height: 20),
          WhiteCard(
            child: Column(
              children: [
                DropdownField<String>(
                  label: 'Section',
                  value: selectedSection,
                  items: sectionOptions,
                  itemLabel: (v) => v,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      selectedSection = v;
                      final first = course.schedules.firstWhere(
                        (s) => s.section == v,
                      );
                      selectedDate = first.date;
                      selectedTime = first.timeLabel;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownField<String>(
                  label: 'Date',
                  value: selectedDate,
                  items: dateOptions,
                  itemLabel: (v) => v,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      selectedDate = v;
                      selectedTime = course.schedules
                          .firstWhere(
                            (s) => s.section == selectedSection && s.date == v,
                          )
                          .timeLabel;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownField<String>(
                  label: 'Time',
                  value: selectedTime,
                  items: timeOptions,
                  itemLabel: (v) => v,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => selectedTime = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Confirm',
            onPressed: () => widget.controller.confirmSession(selectedSession),
          ),
        ],
      ),
    );
  }
}

// ── Generate Code View ────────────────────────────────────────────────────────

class AttendanceGenerateCodeView extends StatelessWidget {
  const AttendanceGenerateCodeView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final course = controller.selectedCourse!;
    final session = controller.selectedSession!;

    return AppScaffold(
      title: 'Generate Attendance Code',
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (controller.gpsError != null) ...[
                GpsErrorCard(message: controller.gpsError!.message),
                const SizedBox(height: 16),
              ],
              CourseHeading(course: course),
              const SizedBox(height: 20),
              InfoStripe(
                icon: Icons.people_alt_outlined,
                label: 'Section',
                value: session.section,
                color: const Color(0xFF2F80ED),
              ),
              const SizedBox(height: 10),
              InfoStripe(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: session.date,
                color: const Color(0xFFFF8A34),
              ),
              const SizedBox(height: 10),
              InfoStripe(
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: session.timeLabel,
                color: const Color(0xFF27AE60),
              ),
              const SizedBox(height: 10),
              InfoStripe(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: session.location.name,
                color: const Color(0xFF9B51E0),
              ),
              const SizedBox(height: 10),
              InfoStripe(
                icon: Icons.groups_outlined,
                label: 'Enrolled',
                value: '${course.enrolledCount} students',
                color: const Color(0xFF2F80ED),
              ),
              const SizedBox(height: 100),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    label: 'Generate Code',
                    icon: Icons.qr_code_2_rounded,
                    onPressed: controller.generateAttendanceCode,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Generated QR View ─────────────────────────────────────────────────────────

class AttendanceGeneratedQrView extends StatelessWidget {
  const AttendanceGeneratedQrView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final course = controller.selectedCourse!;
    final session = controller.selectedSession!;
    final generated = controller.generatedSession!;

    return AppScaffold(
      title: 'Attendance Code',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: controller.backToClasses,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF111827),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Back to Classes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF27AE60)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF27AE60),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Attendance Code Generated.',
                  style: TextStyle(
                    color: Color(0xFF27AE60),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          WhiteCard(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CourseHeading(course: course),
                const SizedBox(height: 6),
                Text(
                  session.section,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        generated.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: QrImageView(
                      data: generated.code,
                      version: QrVersions.auto,
                      size: 180,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF111827),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoPill(label: session.date),
                    const SizedBox(width: 8),
                    _InfoPill(label: session.timeLabel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
      ),
    );
  }
}
