import 'package:flutter/material.dart';

const _kPurple = Color(0xFFAB43FE);
const _kPurpleLight = Color(0xFFF3E8FF);
const _kDanger = Color(0xFFEF4444);
const _kText = Color(0xFF364153);

class AppDrawer extends StatelessWidget {
  final String role;
  const AppDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isStudent = role == 'student';
    final items = isStudent ? _studentItems : _treasuryItems;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: _kPurple,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Text(
                  isStudent ? 'Student' : 'Treasury',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: items
                  .map((item) => _DrawerItem(
                        icon: item.$1,
                        label: item.$2,
                        route: item.$3,
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Logout',
            route: '/login',
            textColor: _kDanger,
            iconColor: _kDanger,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color? textColor;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route && textColor == null;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        color: isActive ? _kPurpleLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: isActive
                    ? _kPurple
                    : (iconColor ?? _kText),
                size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? _kPurple : (textColor ?? _kText),
                  fontSize: 16,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _studentItems = [
  (Icons.dashboard_outlined, 'Dashboard', '/student/dashboard'),
  (Icons.app_registration_outlined, 'Open Registration', '/student/registration'),
  (Icons.menu_book_outlined, 'My Subjects', '/student/subjects'),
  (Icons.class_outlined, 'Co-Curriculum Modules', '/student/modules'),
  (Icons.assignment_outlined, 'Claim Hours', '/student/claim'),
  (Icons.account_balance_wallet_outlined, 'Financial', '/student/financial'),
  (Icons.qr_code_scanner_outlined, 'Attendance Check-In', '/student/checkin'),
  (Icons.assignment_turned_in_outlined, 'Attendance Record', '/student/record'),
];

const _treasuryItems = [
  (Icons.dashboard_outlined, 'Dashboard', '/treasury/dashboard'),
  (Icons.people_outlined, 'Student Payments', '/treasury/payments'),
  (Icons.receipt_long_outlined, 'Fee Records', '/treasury/records'),
];
