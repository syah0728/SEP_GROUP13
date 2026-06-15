import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class StudentSidebar extends StatelessWidget {
  final String activePage;
  final String studentName;
  final String matricNumber;
  final VoidCallback onLogout;

  const StudentSidebar({
    super.key,
    required this.activePage,
    required this.studentName,
    required this.matricNumber,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Purple Profile Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFAB43FE),
            ),
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              matricNumber,
                              style: const TextStyle(
                                color: Color(0xFFDBEAFE),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role',
                        style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 12),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Student',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Sidebar Navigation Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildMenuItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isActive: activePage == 'dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'dashboard') {
                        Navigator.pushReplacementNamed(context, '/student/dashboard');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.app_registration_outlined,
                    label: 'Open Registration',
                    isActive: activePage == 'registration',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'registration') {
                        Navigator.pushReplacementNamed(context, '/student/registration');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.menu_book_outlined,
                    label: 'My Subjects',
                    isActive: activePage == 'subjects',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'subjects') {
                        Navigator.pushReplacementNamed(context, '/student/subjects');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.class_outlined,
                    label: 'Co-Curriculum Modules',
                    isActive: activePage == 'modules',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'modules') {
                        Navigator.pushReplacementNamed(context, '/student/modules');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.assignment_outlined,
                    label: 'Claim Hours',
                    isActive: activePage == 'claim',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'claim') {
                        Navigator.pushReplacementNamed(context, '/student/claim');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Financial',
                    isActive: activePage == 'financial',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'financial') {
                        Navigator.pushReplacementNamed(context, '/student/financial');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.qr_code_scanner_outlined,
                    label: 'Attendance Check-In',
                    isActive: activePage == 'checkin',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'checkin') {
                        Navigator.pushReplacementNamed(context, '/student/checkin');
                      }
                    },
                  ),
                  buildMenuItem(
                    context: context,
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Attendance Record',
                    isActive: activePage == 'record',
                    onTap: () {
                      Navigator.pop(context);
                      if (activePage != 'record') {
                        Navigator.pushReplacementNamed(context, '/student/record');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Divider and Logout Button at the bottom
          const Divider(height: 1),
          buildMenuItem(
            context: context,
            icon: Icons.logout,
            label: 'Logout',
            isActive: false,
            textColor: AppColors.danger,
            iconColor: AppColors.danger,
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    const activeBgColor = Color(0xFFF3E8FF);
    const activeColor = Color(0xFFAB43FE);
    final inactiveColor = textColor ?? const Color(0xFF364153);
    final itemIconColor = isActive ? activeColor : (iconColor ?? inactiveColor);
    final itemTextColor = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isActive ? activeBgColor : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: itemIconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: itemTextColor,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}