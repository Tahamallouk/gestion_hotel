import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
      // success: the Stream in main will navigate to HomeScreen
    } catch (e) {
      final msg = AuthService.formatException(e);
      if (!mounted) return;
      _showSnack(msg, color: Colors.redAccent);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Entrez un email valide.', color: Colors.orange);
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.resetPassword(email);
      if (!mounted) return;
      _showSnack('E-mail de réinitialisation envoyé', color: Colors.green);
    } catch (e) {
      final msg = AuthService.formatException(e);
      if (!mounted) return;
      _showSnack(msg, color: Colors.redAccent);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 72, color: Colors.deepPurple),
                      const SizedBox(height: 12),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: (v) => (v == null || v.isEmpty) ? 'Email requis' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Mot de passe'),
                              validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _forgotPassword,
                                child: const Text('Mot de passe oublié ?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _loading
                                ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                                : SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      child: const Text('Se connecter'),
                                    ),
                                  ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loading
                                  ? null
                                  : () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                                    },
                              child: const Text("Créer un compte"),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
