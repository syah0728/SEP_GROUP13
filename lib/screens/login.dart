// lib/screens/login_screen.dart
// This is the FIRST screen users see.
// It has: username, password, role dropdown, login button.
// Design matches your Figma: blue gradient background, white card.
// For simplicity: we use hardcoded credentials (adab001 / password123).
// You can later connect this to Firebase Authentication.

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers let us READ what user types in text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Track which role is selected in dropdown
  String _selectedRole = 'Pusat Adab';

  // Track if password is hidden or visible
  bool _passwordHidden = true;

  // Track if loading (to show spinner while logging in)
  bool _isLoading = false;

  // Cleanup controllers when screen is destroyed
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Credential table: role → (username, password, route)
  static const _credentials = {
    'Pusat Adab': ('adab001', 'password123', '/dashboard'),
    'Lecturer': ('lecturer001', 'lecturer123', '/lecturer'),
    'Student': ('student001', 'student123', '/student/dashboard'),
  };

  // This function runs when user taps "Login"
  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    final cred = _credentials[_selectedRole];
    if (cred == null) return;

    final (expectedUser, expectedPass, route) = cred;

    if (username == expectedUser && password == expectedPass) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, route);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedRole == 'Pusat Adab'
                ? 'Try: adab001 / password123'
                : _selectedRole == 'Lecturer'
                    ? 'Try: lecturer001 / lecturer123'
                    : 'Try: student001 / student123',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Blue gradient background (matches Figma)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A56DB), // Dark blue top
              Color(0xFF3B82F6), // Lighter blue bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ---- Logo area ----
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A56DB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'UMPSA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Student Academic Management System',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ---- White card with login form ----
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username field
                        const Text('Username',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Enter username',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        const Text('Password',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _passwordHidden, // Hide/show password
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            // Eye icon to toggle password visibility
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _passwordHidden = !_passwordHidden),
                              child: Icon(_passwordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Role dropdown
                        const Text('Role',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Pusat Adab', child: Text('Pusat Adab')),
                            DropdownMenuItem(
                                value: 'Lecturer', child: Text('Lecturer')),
                            DropdownMenuItem(
                                value: 'Student', child: Text('Student')),
                            DropdownMenuItem(
                                value: 'FK Staff', child: Text('FK Staff')),
                            DropdownMenuItem(
                                value: 'Treasury', child: Text('Treasury')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                        ),
                        const SizedBox(height: 8),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF1A56DB)),
                            ),
                          ),
                        ),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleLogin,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.login, color: Colors.white),
                            label: Text(
                              _isLoading ? 'Logging in...' : 'Login',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A56DB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    '© 2026 UMPSA. All rights reserved.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
