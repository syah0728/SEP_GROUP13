import '../../models/manage_cocurriculum/manage_cocurriculum_model.dart';

class ManageCocurriculumController {
  const ManageCocurriculumController();

  ManageCocurriculumModel createInitialState() {
    return const ManageCocurriculumModel(
      moduleId: 'cocurriculum',
      title: 'Manage Cocurriculum',
      description: 'Initial placeholder state for cocurriculum integration.',
    );
  }
}
