import 'package:material_ui/material_ui.dart';

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: const Center(
        child: Text('Le scanner sera intégré en Phase M2'),
      ),
    );
  }
  }