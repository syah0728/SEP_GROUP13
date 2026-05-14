import 'package:flutter/material.dart';

import '../../controllers/manage_attendance/manage_attendance_controller.dart';
import '../../widgets/module_section_card.dart';

class ManageAttendanceScreen extends StatelessWidget {
  ManageAttendanceScreen({super.key, required this.onEnter})
    : controller = const ManageAttendanceController();

  final ManageAttendanceController controller;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final module = controller.buildModule();

    return Scaffold(
      appBar: AppBar(title: Text(module.moduleTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ModuleSectionCard(
            title: module.moduleTitle,
            child: Text(
              module.moduleDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          ModuleSectionCard(
            title: 'Attendance Features',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final feature in module.features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFF2F80ED),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onEnter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Masuk Module',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
