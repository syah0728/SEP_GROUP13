import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'theme/app_theme.dart';
import 'services/attendance_service.dart';
import 'services/firebase_seed_service.dart';
import 'services/session_service.dart';

// ---------- Shared / Shell Screens ----------
import 'screens/actor_selection_view.dart';
import 'screens/lecturer_shell.dart';
import 'screens/student_shell.dart';
import 'screens/login.dart';

// ---------- Module 3: Academic Screens ----------
import 'screens/manage_academic/manage_academic_screen.dart';

// ---------- Module 2: Co-Curriculum Screens ----------
// Adab staff screens (Pusat Adab)
import 'screens/manage_cocurriculum/pusatadab/adab_dashboard.dart';
import 'screens/manage_cocurriculum/pusatadab/attendance_management.dart';
import 'screens/manage_cocurriculum/pusatadab/create_module_adab.dart';
import 'screens/manage_cocurriculum/pusatadab/module_management.dart';
import 'screens/manage_cocurriculum/pusatadab/validate_claim.dart';

// Student screens
import 'screens/manage_cocurriculum/student/claim_credit.dart';
import 'screens/manage_cocurriculum/student/cocu_activity.dart';
import 'screens/manage_cocurriculum/student/std_dashboard.dart';
import 'screens/manage_cocurriculum/student/student_checkin_page.dart';
import 'screens/manage_cocurriculum/student/student_record_page.dart';

// ---------- Module 3: Financial Screens ----------
import 'controllers/manage_financial/financial_controller.dart';
import 'screens/manage_financial/student/student_financial.dart';
import 'screens/manage_financial/treasury/treasury_dashboard.dart';
import 'screens/manage_financial/treasury/student_payments_view.dart';
import 'screens/manage_financial/treasury/fee_records.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Restore whoever was logged in before a page reload so the sidebar/header
  // keeps showing their identity instead of resetting to the demo defaults.
  await AppSession.restore();

  // Seed functions from the base project module (Attendance/Operations)
  await FirebaseAttendanceService().seedIfNeeded();
  await FirebaseSeedService().seedIfNeeded();

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FinancialController>(
      create: (_) => FinancialController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SAMS 2026',
        theme: AppTheme.light().copyWith(
          scaffoldBackgroundColor: AppColors.background,
        ),
        // App starts with the login screen, unless a session was restored
        // after a page reload, in which case go straight back to that role's
        // dashboard.
        home: Builder(
          builder: (context) =>
              MobilePreviewFrame(child: _initialScreen(context)),
        ),

        // Named routes added dynamically for Module 2 cross-navigation
        routes: {
          // Auth / Basic Routes
          '/login': (context) => const LoginScreen(),

          // Lecturer route (Module 1)
          '/lecturer': (context) => LecturerShell(
                lecturerId: AppSession.lecturerId,
                onSwitchActor: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
              ),

          // Adab staff routes — Module 2: Co-Curriculum (Orange theme)
          '/dashboard': (context) => const AdabDashboard(),
          '/modules': (context) => const ModuleManagementPage(),
          '/create-module': (context) => const CreateModuleAdab(),
          '/claims': (context) => const ValidateClaimsScreen(),
          '/attendance': (context) => const AttendanceManagementScreen(),

          // FK Staff routes — Module 3: Academic
          '/fkstaff/dashboard': (context) => const ManageAcademicScreen(),

          // Student routes — Module 2: Co-Curriculum (Purple theme)
          '/student/dashboard': (context) => const StudentDashboard(),
          '/student/modules': (context) => const CoCurriculumModulesScreen(),
          '/student/claim': (context) => const ClaimCreditScreen(),
          '/student/checkin': (context) => const StudentCheckinPage(),
          '/student/record': (context) => const StudentRecordPage(),

          // Student routes — Module 3: Financial
          '/student/financial': (context) =>
              StudentFinancialPage(studentId: AppSession.matricId),

          // Treasury routes — Module 3: Financial
          '/treasury/dashboard': (context) => const TreasuryDashboardView(),
          '/treasury/payments': (context) =>
              const TreasuryStudentPaymentsView(),
          '/treasury/records': (context) => const TreasuryFeeRecordsView(),
          '/treasury/fee-records': (context) => const TreasuryFeeRecordsView(),
        },
      ),
    );
  }

  /// Picks the first screen to show based on a session restored from local
  /// storage, falling back to the login screen if nobody is logged in.
  Widget _initialScreen(BuildContext context) {
    switch (AppSession.role) {
      case 'Student':
        return const StudentDashboard();
      case 'Lecturer':
        return LecturerShell(
          lecturerId: AppSession.lecturerId,
          onSwitchActor: () =>
              Navigator.pushReplacementNamed(context, '/login'),
        );
      case 'Pusat Adab':
        return const AdabDashboard();
      case 'FK Staff':
        return const ManageAcademicScreen();
      case 'Treasury':
        return const TreasuryDashboardView();
      default:
        return const LoginScreen();
    }
  }
}

class AppFlowRoot extends StatefulWidget {
  const AppFlowRoot({super.key});

  @override
  State<AppFlowRoot> createState() => _AppFlowRootState();
}

class _AppFlowRootState extends State<AppFlowRoot> {
  AppActor? selectedActor;

  void _selectActor(AppActor actor) {
    setState(() => selectedActor = actor);
  }

  void _switchActor() {
    setState(() => selectedActor = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (selectedActor) {
        null => ActorSelectionView(
          key: const ValueKey('actor-selection'),
          onSelectActor: _selectActor,
        ),
        AppActor.lecturer => LecturerShell(
          key: const ValueKey('lecturer'),
          lecturerId: 'LE210145',
          onSwitchActor: _switchActor,
        ),
        AppActor.student => StudentShell(
          key: const ValueKey('student'),
          studentId: 'A20CS1001',
          onSwitchActor: _switchActor,
        ),
      },
    );
  }
}

class MobilePreviewFrame extends StatelessWidget {
  const MobilePreviewFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 520) {
          return child;
        }

        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 844.0;
        final phoneHeight = min(844.0, max(0.0, availableHeight - 32));

        return ColoredBox(
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: Container(
              width: 390,
              height: phoneHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: Size(390, phoneHeight)),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
