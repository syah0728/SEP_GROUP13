class ManageFinancialModel {
  const ManageFinancialModel({
    required this.moduleId,
    required this.title,
    this.description = '',
  });

  final String moduleId;
  final String title;
  final String description;
}
