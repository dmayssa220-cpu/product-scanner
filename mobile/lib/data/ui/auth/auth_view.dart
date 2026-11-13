import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'auth_viewmodel.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<AuthViewModel>();
    final ok = _isRegister
        ? await vm.register(_emailCtrl.text.trim(), _passwordCtrl.text)
        : await vm.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Inscription' : 'Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
            ),
            if (vm.error != null) ...[
              const SizedBox(height: 16),
              Text(vm.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: vm.loading ? null : _submit,
                child: vm.loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isRegister ? "S'inscrire" : 'Se connecter'),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isRegister = !_isRegister),
              child: Text(_isRegister ? 'Déjà un compte ? Se connecter' : 'Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}