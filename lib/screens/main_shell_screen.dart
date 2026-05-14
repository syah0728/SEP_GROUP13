import 'package:flutter/material.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: child));
  }
}
