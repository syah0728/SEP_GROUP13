import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session_service.dart';
import '../../utils/app_colors.dart';

class AdabSidebar extends StatelessWidget {
  final String activePage; // 'dashboard', 'modules', 'claims', 'attendance'
  final int pendingClaimsCount; // badge number for Validate Claims
  final VoidCallback onLogout;

  const AdabSidebar({
    super.key,
    required this.activePage,
    required this.pendingClaimsCount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          // ---------- Orange Header ----------
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(51),
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                // Name and ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppSession.adabName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.56,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppSession.adabId,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFDBEAFE),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Role badge
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFDBEAFE),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pusat Adab Staff',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ---------- Menu Items ----------
          buildMenuItem(
            context: context,
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isActive: activePage == 'dashboard',
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'dashboard') {
                Navigator.pushReplacementNamed(context, '/dashboard');
              }
            },
          ),
          buildMenuItem(
            context: context,
            icon: Icons.calendar_month_outlined,
            label: 'Module Management',
            isActive: activePage == 'modules',
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'modules') {
                Navigator.pushReplacementNamed(context, '/modules');
              }
            },
          ),
          buildMenuItem(
            context: context,
            icon: Icons.check_circle_outline,
            label: 'Validate Claims',
            isActive: activePage == 'claims',
            badgeCount: pendingClaimsCount,
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'claims') {
                Navigator.pushReplacementNamed(context, '/claims');
              }
            },
          ),
          buildMenuItem(
            context: context,
            icon: Icons.article_outlined,
            label: 'Student Attendance',
            isActive: activePage == 'attendance',
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'attendance') {
                Navigator.pushReplacementNamed(context, '/attendance');
              }
            },
          ),
          const Spacer(),
          // Logout
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
    int badgeCount = 0,
    Color? textColor,
    Color? iconColor,
  }) {
    const activeColor = AppColors.primary;
    final inactiveColor = textColor ?? const Color(0xFF364153);
    final itemIconColor = isActive ? activeColor : (iconColor ?? inactiveColor);
    final itemTextColor = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isActive ? AppColors.primaryLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: itemIconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: itemTextColor,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
