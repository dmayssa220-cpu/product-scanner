import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/history_entry.dart';
import '../../data/repositories/history_repository.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.read<HistoryRepository>().list();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des scans')),
      body: FutureBuilder<List<HistoryEntry>>(
        future: history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  'Impossible de charger l’historique : ${snapshot.error}'),
            );
          }

          final entries = snapshot.data ?? const <HistoryEntry>[];
          if (entries.isEmpty) {
            return const Center(child: Text('Aucun scan pour le moment.'));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(entry.productName ?? 'Produit indisponible'),
                subtitle: Text(
                  '${entry.productBrand ?? 'Marque inconnue'} · '
                  '${entry.scannedAt.toLocal()}',
                ),
                onTap: entry.productId == null
                    ? null
                    : () => context.push('/product/${entry.productId}'),
              );
            },
          );
        },
      ),
    );
  }
}
