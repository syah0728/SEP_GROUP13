import 'package:flutter/material.dart';

import '../../../controllers/manage_attendance/attendance_controller.dart';
import '../../../models/manage_attendance/attendance_models.dart';
import 'attendance_management.dart';

// ── Attendance Record Selection View ──────────────────────────────────────────

class AttendanceRecordSelectionView extends StatefulWidget {
  const AttendanceRecordSelectionView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  State<AttendanceRecordSelectionView> createState() =>
      _AttendanceRecordSelectionViewState();
}

class _AttendanceRecordSelectionViewState
    extends State<AttendanceRecordSelectionView> {
  late Course selectedCourse;
  late String selectedSection;
  late String selectedDate;
  late String selectedTime;

  @override
  void initState() {
    super.initState();
    selectedCourse =
        widget.controller.selectedRecordCourse ??
        widget.controller.courses.first;
    final s =
        widget.controller.selectedRecordSession ??
        selectedCourse.schedules.first;
    selectedSection = s.section;
    selectedDate = s.date;
    selectedTime = s.timeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final sectionOptions = selectedCourse.schedules
        .map((s) => s.section)
        .toSet()
        .toList();
    final dateOptions = selectedCourse.schedules
        .where((s) => s.section == selectedSection)
        .map((s) => s.date)
        .toSet()
        .toList();
    final timeOptions = selectedCourse.schedules
        .where((s) => s.section == selectedSection && s.date == selectedDate)
        .map((s) => s.timeLabel)
        .toList();

    if (!dateOptions.contains(selectedDate)) selectedDate = dateOptions.first;
    if (!timeOptions.contains(selectedTime)) selectedTime = timeOptions.first;

    final session = selectedCourse.schedules.firstWhere(
      (s) =>
          s.section == selectedSection &&
          s.date == selectedDate &&
          s.timeLabel == selectedTime,
    );

    return AppScaffold(
      title: 'Attendance Record',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Select Class',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          WhiteCard(
            child: Column(
              children: [
                DropdownField<Course>(
                  label: 'Class',
                  value: selectedCourse,
                  items: widget.controller.courses,
                  itemLabel: (c) => '${c.courseName} (${c.courseCode})',
                  onChanged: (c) {
                    if (c == null) return;
                    setState(() {
                      selectedCourse = c;
                      final s = c.schedules.first;
                      selectedSection = s.section;
                      selectedDate = s.date;
                      selectedTime = s.timeLabel;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownField<String>(
                  label: 'Section',
                  value: selectedSection,
                  items: sectionOptions,
                  itemLabel: (v) => v,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      selectedSection = v;
                      final s = selectedCourse.schedules.firstWhere(
                        (s) => s.section == v,
                      );
                      selectedDate = s.date;
                      selectedTime = s.timeLabel;
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
                      selectedTime = selectedCourse.schedules
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
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'View Records',
            onPressed: () {
              widget.controller.setRecordSelection(
                course: selectedCourse,
                session: session,
              );
              widget.controller.openAttendanceRecords();
            },
          ),
        ],
      ),
    );
  }
}

// ── Attendance Record List View ───────────────────────────────────────────────

class AttendanceRecordListView extends StatefulWidget {
  const AttendanceRecordListView({super.key, required this.controller});
  final AttendanceController controller;

  @override
  State<AttendanceRecordListView> createState() =>
      _AttendanceRecordListViewState();
}

class _AttendanceRecordListViewState extends State<AttendanceRecordListView> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final course = widget.controller.selectedRecordCourse!;
    final session = widget.controller.selectedRecordSession!;
    final records = widget.controller.attendanceRecords.where((r) {
      final q = searchText.toLowerCase();
      return r.name.toLowerCase().contains(q) ||
          r.matricId.toLowerCase().contains(q);
    }).toList();

    final presentCount = records
        .where((r) => r.status == AttendanceStatus.present)
        .length;

    return AppScaffold(
      title: 'Attendance Record',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            course.courseName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(
            course.courseCode,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F80ED),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FilterTag(label: session.section),
              const SizedBox(width: 6),
              _FilterTag(label: session.date),
              const SizedBox(width: 6),
              _FilterTag(label: session.timeLabel),
            ],
          ),
          if (widget.controller.hasRecordUpdate) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF27AE60)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF27AE60),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Attendance record updated successfully!',
                    style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryBadge(
                label: 'Present',
                count: presentCount,
                color: const Color(0xFF27AE60),
              ),
              const SizedBox(width: 8),
              _SummaryBadge(
                label: 'Absent',
                count: records.length - presentCount,
                color: const Color(0xFFFF4B66),
              ),
              const SizedBox(width: 8),
              _SummaryBadge(
                label: 'Total',
                count: records.length,
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: TextField(
              onChanged: (v) => setState(() => searchText = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                prefixIcon: const Icon(Icons.search, size: 18),
                hintText: 'Search by name or matric...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No records found for this session.',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            _AttendanceTable(
              records: records,
              onStatusChanged: (record, status) =>
                  widget.controller.updateAttendanceStatus(
                    recordId: record.recordId,
                    status: status,
                  ),
            ),
        ],
      ),
    );
  }
}

class _FilterTag extends StatelessWidget {
  const _FilterTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF2F80ED),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$count ',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  const _AttendanceTable({
    required this.records,
    required this.onStatusChanged,
  });

  final List<StudentAttendanceRecord> records;
  final void Function(StudentAttendanceRecord, AttendanceStatus)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 36,
            color: const Color(0xFFE8EDFF),
            child: const Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Center(
                    child: Text(
                      'MATRIC',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'NAME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Center(
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final record in records)
            _RecordRow(
              record: record,
              onStatusChanged: (status) => onStatusChanged(record, status),
            ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record, required this.onStatusChanged});

  final StudentAttendanceRecord record;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status == AttendanceStatus.present;
    final fg = isPresent ? const Color(0xFF27AE60) : const Color(0xFFFF4B66);
    final bg = isPresent ? const Color(0xFFE8FFF3) : const Color(0xFFFFEEF2);

    return Container(
      height: 46,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Center(
              child: Text(
                record.matricId,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              record.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Center(
              child: PopupMenuButton<AttendanceStatus>(
                padding: EdgeInsets.zero,
                tooltip: 'Change status',
                onSelected: onStatusChanged,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: AttendanceStatus.present,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Color(0xFF27AE60),
                        ),
                        const SizedBox(width: 8),
                        const Text('Present', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: AttendanceStatus.absent,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 14,
                          color: Color(0xFFFF4B66),
                        ),
                        const SizedBox(width: 8),
                        const Text('Absent', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  height: 26,
                  width: 74,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: fg.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPresent ? Icons.check : Icons.close,
                        size: 11,
                        color: fg,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          fontSize: 10,
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, size: 14, color: fg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
