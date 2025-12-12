import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _authService.registerWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      _showSnack('Compte créé avec succès', color: Colors.green);
      Navigator.pop(context);
    } catch (e) {
      final msg = AuthService.formatException(e);
      if (!mounted) return;
      _showSnack(msg, color: Colors.redAccent);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: "Email"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.isEmpty) ? "Email requis" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fullNameCtrl,
                          decoration: const InputDecoration(labelText: "Nom complet"),
                          keyboardType: TextInputType.name,
                          validator: (v) => (v == null || v.isEmpty) ? "Nom complet requis" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(labelText: "Téléphone"),
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.isEmpty) ? "Téléphone requis" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Mot de passe"),
                          validator: (v) => (v == null || v.isEmpty) ? "Mot de passe requis" : null,
                        ),
                        const SizedBox(height: 16),
                        _loading
                            ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                            : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  child: const Text("Créer un compte"),
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
      ),
    );
  }
}
