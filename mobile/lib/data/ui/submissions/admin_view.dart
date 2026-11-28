import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/submissions_repository.dart';

class SubmissionsAdminView extends StatefulWidget {
  const SubmissionsAdminView({super.key});
  @override
  State<SubmissionsAdminView> createState() => _SubmissionsAdminViewState();
}

class _SubmissionsAdminViewState extends State<SubmissionsAdminView> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<SubmissionsRepository>().pendingAdmin();
  }

  void _reload() => setState(() => _future = context.read<SubmissionsRepository>().pendingAdmin());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modération')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('Aucune soumission en attente'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final s = items[i];
              final payload = s['payload'] as Map<String, dynamic>;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payload['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (payload['brand'] != null) Text(payload['brand']),
                      const SizedBox(height: 8),
                      Text('Code-barres : ${s['barcode'] ?? '—'}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await context.read<SubmissionsRepository>().reject(s['id'], 'Doublon ou données invalides');
                              _reload();
                            },
                            child: const Text('Rejeter', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              await context.read<SubmissionsRepository>().approve(s['id']);
                              _reload();
                            },
                            child: const Text('Approuver'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}