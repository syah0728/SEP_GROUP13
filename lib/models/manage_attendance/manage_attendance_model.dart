class ManageAttendanceModel {
  const ManageAttendanceModel({
    required this.moduleId,
    required this.moduleTitle,
    required this.moduleDescription,
    required this.features,
  });

  final String moduleId;
  final String moduleTitle;
  final String moduleDescription;
  final List<String> features;
}
