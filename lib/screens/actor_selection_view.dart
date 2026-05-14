import 'package:flutter/material.dart';

enum AppActor { lecturer, student }

class ActorSelectionView extends StatelessWidget {
  const ActorSelectionView({super.key, required this.onSelectActor});

  final ValueChanged<AppActor> onSelectActor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A3E), Color(0xFF0D0D25)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x262F80ED), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x202F80ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x402F80ED)),
                    ),
                    child: const Text(
                      'SAMS 2026',
                      style: TextStyle(
                        color: Color(0xFF9CCBFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Attendance &\nOperations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Smart Attendance Management System',
                    style: TextStyle(
                      color: Color(0xFF8892A4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select your role to continue',
              style: TextStyle(
                color: Color(0xFF8892A4),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            _ActorCard(
              icon: Icons.school_rounded,
              title: 'Lecturer',
              subtitle: 'Generate attendance code, QR code & manage records',
              gradient: const LinearGradient(
                colors: [Color(0xFF2F80ED), Color(0xFF1A5FBF)],
              ),
              onTap: () => onSelectActor(AppActor.lecturer),
            ),
            const SizedBox(height: 14),
            _ActorCard(
              icon: Icons.person_rounded,
              title: 'Student',
              subtitle: 'Submit attendance via QR scan or manual code',
              gradient: const LinearGradient(
                colors: [Color(0xFF9B2EF4), Color(0xFF6B1EAA)],
              ),
              onTap: () => onSelectActor(AppActor.student),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorCard extends StatelessWidget {
  const _ActorCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
