// screens/manage_cocurriculum/create_module_adab.dart
// Form screen for Adab staff to create a new co-curriculum module.
// Opened from module_management.dart.

import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../../models/manage_cocurriculum/module.dart';
import '../../../utils/app_colors.dart';

class CreateModuleAdab extends StatefulWidget {
  const CreateModuleAdab({super.key});

  @override
  State<CreateModuleAdab> createState() => CreateModuleAdabState();
}

class CreateModuleAdabState extends State<CreateModuleAdab> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final lecturerController = TextEditingController();
  final venueController = TextEditingController();
  final maxParticipantsController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  final FirebaseService service = FirebaseService();
  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    lecturerController.dispose();
    venueController.dispose();
    maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: startTime);
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: endTime);
    if (picked != null) setState(() => endTime = picked);
  }

  Future<void> saveModule() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSaving = true);
    final module = ModuleModel(
      id: '', // Firestore assigns the ID automatically
      title: titleController.text,
      date: "${selectedDate.day} ${_month(selectedDate.month)} ${selectedDate.year}",
      startTime: startTime.format(context),
      endTime: endTime.format(context),
      lecturer: lecturerController.text,
      venue: venueController.text,
      maxParticipants: int.tryParse(maxParticipantsController.text) ?? 50,
      registeredCount: 0,
    );
    final code = await service.addModule(module);
    if (mounted) {
      setState(() => isSaving = false);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Module Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share this code with students at the venue:'),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  String _month(int m) => const [
        "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
      ][m - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Module"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: "Module Title", border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              // Date picker — full width
              OutlinedButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                    "${selectedDate.day} ${_month(selectedDate.month)} ${selectedDate.year}"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              // Start & end time — side by side
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickStartTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(startTime.format(context)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickEndTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(endTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lecturerController,
                decoration: const InputDecoration(
                    labelText: "Lecturer Name", border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: venueController,
                decoration: const InputDecoration(
                    labelText: "Venue", border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Max Participants",
                    border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveModule,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text("Save",
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}