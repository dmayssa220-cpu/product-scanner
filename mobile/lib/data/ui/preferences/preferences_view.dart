import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../repositories/preferences_repository.dart';

const _allergenOptions = {
  'gluten': 'Gluten',
  'lactose': 'Lactose',
  'arachides': 'Arachides',
  'fruits_a_coque': 'Fruits à coque',
  'soja': 'Soja',
  'oeufs': 'Œufs',
};
const _dietOptions = {
  'halal': 'Halal',
  'vegetarien': 'Végétarien',
  'vegan': 'Vegan',
};

class PreferencesView extends StatefulWidget {
  const PreferencesView({super.key});
  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  final Set<String> _allergens = {};
  final Set<String> _diets = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await context.read<PreferencesRepository>().get();
    setState(() {
      _allergens.addAll(prefs.allergens);
      _diets.addAll(prefs.diets);
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = UserPreferences(
      allergens: _allergens.toList(),
      diets: _diets.toList(),
    );
    await context.read<PreferencesRepository>().save(prefs);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préférences enregistrées')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mes préférences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Allergènes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergenOptions.entries
                .map(
                  (entry) => FilterChip(
                    label: Text(entry.value),
                    selected: _allergens.contains(entry.key),
                    onSelected: (selected) => setState(() {
                      selected
                          ? _allergens.add(entry.key)
                          : _allergens.remove(entry.key);
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('Régimes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietOptions.entries
                .map(
                  (entry) => FilterChip(
                    label: Text(entry.value),
                    selected: _diets.contains(entry.key),
                    onSelected: (selected) => setState(() {
                      selected
                          ? _diets.add(entry.key)
                          : _diets.remove(entry.key);
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
