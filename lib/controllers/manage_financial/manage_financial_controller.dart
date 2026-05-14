import '../../models/manage_financial/manage_financial_model.dart';

class ManageFinancialController {
  const ManageFinancialController();

  ManageFinancialModel createInitialState() {
    return const ManageFinancialModel(
      moduleId: 'financial',
      title: 'Manage Financial',
      description: 'Initial placeholder state for financial integration.',
    );
  }
}
