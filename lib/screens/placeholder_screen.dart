// lib/screens/placeholder_screen.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/header.dart'; // Importe seu CustomHeader

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lilasClaro,
      body: Column(
        children: [
          CustomHeader(showBackButton: true, title: title, showCartIcon: true),
          Expanded(
            child: Center(
              child: Text(
                'Tela: $title\n(Em construção)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: AppColors.primaria, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}