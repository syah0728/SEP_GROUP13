import 'package:flutter/material.dart';

const kTeal = Color(0xFF00BFA5);

class AppDrawer extends StatelessWidget {
  final String role; // 'student' or 'treasury'

  const AppDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isTreasury = role == 'treasury';

    return Drawer(
      child: Column(
        children: [
          // ── Header: user info ─────────────────────────────
          Container(
            color: kTeal,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name changes based on role
                      Text(
                        isTreasury ? 'Siti Aminah' : 'Ahmad Razif',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ID changes based on role
                      Text(
                        isTreasury ? 'TREASURY001' : 'CB23001',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      // Role label
                      Text(
                        isTreasury ? 'Treasury Officer' : 'Student',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
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

          // ── Navigation items ──────────────────────────────
          // Dashboard — shown for both roles
          ListTile(
            leading: const Icon(Icons.dashboard, color: kTeal),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),

          // Treasury-only nav items
          if (isTreasury) ...[
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Student Payments'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Fee Records'),
              onTap: () => Navigator.pop(context),
            ),
          ],

          // Student-only nav items
          if (!isTreasury) ...[
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Financial'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () => Navigator.pop(context),
            ),
          ],

          const Spacer(),

          // ── Logout ─────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: call auth sign out when login module is ready
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
