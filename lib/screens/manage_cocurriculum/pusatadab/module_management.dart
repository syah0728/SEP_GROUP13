// screens/manage_cocurriculum/module_management.dart
// Adab staff screen: list, edit, and delete co-curriculum modules.
// Also contains EditModulePage (inline, same file).
// Theme: orange (AppColors.primary) header + white body.

import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../../models/manage_cocurriculum/module.dart';
import '../../../widgets/adab_sidebar.dart';
import '../../../utils/app_colors.dart';
import 'create_module_adab.dart';

class ModuleManagementPage extends StatefulWidget {
  const ModuleManagementPage({super.key});

  @override
  State<ModuleManagementPage> createState() => ModuleManagementPageState();
}

class ModuleManagementPageState extends State<ModuleManagementPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FirebaseService service = FirebaseService();

  @override
  void initState() {
    super.initState();
    service.seedSampleData();
  }

  Future<void> deleteModule(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.deleteModule(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module deleted successfully')),
        );
      }
    }
  }

  void editModule(ModuleModel module) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditModulePage(module: module)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: StreamBuilder<int>(
        stream: service.getPendingClaimsCount(),
        builder: (context, snapshot) => AdabSidebar(
          activePage: 'modules',
          pendingClaimsCount: snapshot.data ?? 0,
          onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Orange header
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => scaffoldKey.currentState?.openDrawer(),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Module Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.notifications_none, color: Colors.white),
                        SizedBox(width: 12),
                        Icon(Icons.person_outline, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Button to open the Create Module form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateModuleAdab(),
                    ),
                  ).then((_) => setState(() {})),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Create New Module",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "All Modules",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2939),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Live module list from Firestore
              Expanded(
                child: StreamBuilder<List<ModuleModel>>(
                  stream: service.getModules(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final modules = snapshot.data!;
                    if (modules.isEmpty) {
                      return const Center(
                        child: Text(
                          "No modules. Tap 'Create New Module' to add one.",
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final m = modules[index];
                        final pct = m.maxParticipants > 0
                            ? m.registeredCount / m.maxParticipants
                            : 0.0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2939),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _row(Icons.calendar_today, m.date),
                                const SizedBox(height: 8),
                                _row(Icons.location_on, m.venue),
                                const SizedBox(height: 8),
                                _row(
                                  Icons.access_time,
                                  "${m.startTime} - ${m.endTime}",
                                ),
                                const SizedBox(height: 8),
                                _row(
                                  Icons.people,
                                  "${m.registeredCount}/${m.maxParticipants} registered",
                                ),
                                const SizedBox(height: 8),
                                // Attendance code for students
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primary.withAlpha(80),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.qr_code,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Attendance Code: ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        m.code.isNotEmpty ? m.code : '—',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Registration progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    color: AppColors.success,
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => editModule(m),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text("Edit"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            deleteModule(m.id, m.title),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                        ),
                                        label: const Text("Delete"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.danger,
                                          side: const BorderSide(
                                            color: AppColors.danger,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A5565)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF4A5565), fontSize: 14),
        ),
      ],
    );
  }
}

// ---------- EDIT MODULE PAGE ----------
class EditModulePage extends StatefulWidget {
  final ModuleModel module;
  const EditModulePage({super.key, required this.module});

  @override
  State<EditModulePage> createState() => EditModulePageState();
}

class EditModulePageState extends State<EditModulePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController lecturerController;
  late TextEditingController venueController;
  late TextEditingController maxController;
  late TextEditingController registeredController;
  late DateTime date;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  final FirebaseService service = FirebaseService();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.module.title);
    lecturerController = TextEditingController(text: widget.module.lecturer);
    venueController = TextEditingController(text: widget.module.venue);
    maxController = TextEditingController(
      text: widget.module.maxParticipants.toString(),
    );
    registeredController = TextEditingController(
      text: widget.module.registeredCount.toString(),
    );
    date = _parseDate(widget.module.date);
    startTime = _parseTime(widget.module.startTime);
    endTime = _parseTime(widget.module.endTime);
  }

  DateTime _parseDate(String s) {
    try {
      final p = s.split(' ');
      if (p.length == 3) {
        return DateTime(int.parse(p[2]), _monthNum(p[1]), int.parse(p[0]));
      }
    } catch (_) {}
    return DateTime.now();
  }

  int _monthNum(String m) =>
      const {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      }[m] ??
      1;

  TimeOfDay _parseTime(String s) {
    try {
      final parts = s.split(' ');
      final tp = parts[0].split(':');
      int h = int.parse(tp[0]);
      final min = int.parse(tp[1]);
      if (parts[1].toUpperCase() == 'PM' && h != 12) h += 12;
      if (parts[1].toUpperCase() == 'AM' && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: min);
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _monthName(int m) => const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ][m - 1];

  Future<void> saveChanges() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSaving = true);
    final updated = ModuleModel(
      id: widget.module.id,
      title: titleController.text,
      date: "${date.day} ${_monthName(date.month)} ${date.year}",
      startTime: startTime.format(context),
      endTime: endTime.format(context),
      lecturer: lecturerController.text,
      venue: venueController.text,
      maxParticipants: int.parse(maxController.text),
      registeredCount: int.parse(registeredController.text),
    );
    await service.updateModule(updated);
    if (mounted) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Module updated")));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    lecturerController.dispose();
    venueController.dispose();
    maxController.dispose();
    registeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Module"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Module Title"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (p != null) setState(() => date = p);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        "${date.day} ${_monthName(date.month)} ${date.year}",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final p = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (p != null) setState(() => startTime = p);
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(startTime.format(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final p = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (p != null) setState(() => endTime = p);
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(endTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lecturerController,
                decoration: const InputDecoration(labelText: "Lecturer"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: venueController,
                decoration: const InputDecoration(labelText: "Venue"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Max Participants",
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: registeredController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Registered Count",
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
