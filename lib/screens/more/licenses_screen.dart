import 'package:flutter/material.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationName: 'Опорник',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.school,
        size: 100,
        color: Colors.blue,
      ),
      applicationLegalese: '© 2025 гусьпроект с ❤️',
    );
  }
}
