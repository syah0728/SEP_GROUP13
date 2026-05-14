import '../../models/manage_academic/manage_academic_model.dart';

class ManageAcademicController {
  const ManageAcademicController();

  ManageAcademicModel createInitialState() {
    return const ManageAcademicModel(
      moduleId: 'academic',
      title: 'Manage Academic',
      description: 'Initial placeholder state for academic integration.',
    );
  }
}
