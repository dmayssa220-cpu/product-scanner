import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/submissions_repository.dart';

class SubmissionFormView extends StatefulWidget {
  const SubmissionFormView({super.key, this.barcode});
  final String? barcode;

  @override
  State<SubmissionFormView> createState() => _SubmissionFormViewState();
}

class _SubmissionFormViewState extends State<SubmissionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  int _processingLevel = 3;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _categoryCtrl.dispose();
    _ingredientsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final ingredients = _ingredientsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => <String, dynamic>{'name': s, 'risk': 'low'})
          .toList();
      await context.read<SubmissionsRepository>().submit(
            barcode: widget.barcode,
            name: _nameCtrl.text.trim(),
            brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
            category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
            ingredients: ingredients,
            processingLevel: _processingLevel,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soumission envoyée. En attente de validation.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proposer un produit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.barcode != null) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text('Code-barres : ${widget.barcode}'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom du produit *'),
              validator: (v) => (v == null || v.trim().length < 2) ? 'Nom requis (min. 2 car.)' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Marque'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredientsCtrl,
              decoration: const InputDecoration(
                labelText: 'Ingrédients (séparés par des virgules)',
                hintText: 'farine, sucre, huile',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Niveau de transformation (NOVA)'),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
              ],
              selected: {_processingLevel},
              onSelectionChanged: (s) => setState(() => _processingLevel = s.first),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
              label: const Text('Envoyer la proposition'),
            ),
          ],
        ),
      ),
    );
  }
}