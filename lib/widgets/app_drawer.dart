import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String role;
  const AppDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF7B2FBE)),
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      role[0].toUpperCase() + role.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/$role/dashboard');
            },
          ),
          _DrawerItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Financial',
            onTap: () => Navigator.pop(context),
            isActive: true,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF7B2FBE);
    const activeBg = Color(0xFFF3E8FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isActive ? activeBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isActive ? activeColor : const Color(0xFF364153), size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : const Color(0xFF364153),
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
