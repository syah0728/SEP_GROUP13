import 'package:flutter/material.dart';
import '../services/session_service.dart';

const _kTeal = Color(0xFF00BFA5);

class TreasuryDrawer extends StatelessWidget {
  final String activePage; // 'dashboard' | 'payments' | 'fee-records'
  final VoidCallback onLogout;

  const TreasuryDrawer({
    super.key,
    required this.activePage,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ── Header: user info ─────────────────────────────
          Container(
            color: _kTeal,
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
                      Text(
                        AppSession.treasuryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppSession.treasuryId,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        'Treasury Officer',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // ── Navigation items ──────────────────────────────
          ListTile(
            leading: Icon(
              Icons.dashboard,
              color: activePage == 'dashboard' ? _kTeal : null,
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: activePage == 'dashboard' ? _kTeal : null,
                fontWeight: activePage == 'dashboard' ? FontWeight.w600 : null,
              ),
            ),
            tileColor: activePage == 'dashboard'
                ? const Color(0xFFE0F7F4)
                : Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'dashboard') {
                Navigator.pushReplacementNamed(context, '/treasury/dashboard');
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.people_outline,
              color: activePage == 'payments' ? _kTeal : null,
            ),
            title: Text(
              'Student Payments',
              style: TextStyle(
                color: activePage == 'payments' ? _kTeal : null,
                fontWeight: activePage == 'payments' ? FontWeight.w600 : null,
              ),
            ),
            tileColor: activePage == 'payments'
                ? const Color(0xFFE0F7F4)
                : Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'payments') {
                Navigator.pushReplacementNamed(context, '/treasury/payments');
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.receipt_long_outlined,
              color: activePage == 'fee-records' ? _kTeal : null,
            ),
            title: Text(
              'Fee Records',
              style: TextStyle(
                color: activePage == 'fee-records' ? _kTeal : null,
                fontWeight:
                    activePage == 'fee-records' ? FontWeight.w600 : null,
              ),
            ),
            tileColor: activePage == 'fee-records'
                ? const Color(0xFFE0F7F4)
                : Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              if (activePage != 'fee-records') {
                Navigator.pushReplacementNamed(
                    context, '/treasury/fee-records');
              }
            },
          ),

          const Spacer(),

          // ── Logout ─────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }
}
