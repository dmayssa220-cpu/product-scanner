import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 96),
            const SizedBox(height: 24),
            const Text(
              'Scannez ou recherchez un produit',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/scan'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner un code-barres'),
            ),
          ],
        ),
      ),
    );
  }
}