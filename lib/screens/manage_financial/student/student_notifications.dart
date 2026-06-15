// ============================================================
// student_notifications_page.dart
// Screen  : Notifications
// Role    : STUDENT
// Path    : screens/manage_financial/student/
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';

const kPurple = Color(0xFF7B2FBE);

class StudentNotificationsPage extends StatefulWidget {
  final String studentId;
  const StudentNotificationsPage({super.key, required this.studentId});

  @override
  State<StudentNotificationsPage> createState() =>
      _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<FinancialController>().loadNotifications(
        widget.studentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();
    final notifs = ctrl.notifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade50,

      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : notifs.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              itemBuilder: (_, i) => _NotifCard(notif: notifs[i]),
            ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  const _NotifCard({required this.notif});

  _IconData _icon() {
    switch (notif.type) {
      case 'confirmed':
        return _IconData(Icons.check_circle_outline, const Color(0xFF4CAF50));
      case 'new_semester':
        return _IconData(Icons.school_outlined, const Color(0xFF2196F3));
      case 'blocked':
        return _IconData(Icons.block, Colors.red);
      case 'unblocked':
        return _IconData(Icons.check_circle_outline, const Color(0xFF4CAF50));
      default:
        return _IconData(Icons.notifications_outlined, const Color(0xFFFF9800));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ic = _icon();
    final dateStr = DateFormat('yyyy-MM-dd').format(notif.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ic.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ic.icon, color: ic.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif.message,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconData {
  final IconData icon;
  final Color color;
  const _IconData(this.icon, this.color);
}
