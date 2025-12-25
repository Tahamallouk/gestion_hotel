import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/screens/auth/register_screen.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

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
  bool _obscure = true;

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
      // Get role during login
      final role = await _authService.signInWithEmailAndGetRole(
        _emailCtrl.text.trim(), 
        _passCtrl.text.trim()
      );
      
      print('🎯 Role récupéré: $role'); // Log console pour afficher le rôle
      
      // Success: the Stream in main will handle navigation automatically
      // based on the user's role in AppShell
      
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal, vertical: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXl),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.lock_outline, color: AppColors.textOnPrimary, size: 28),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Heureux de vous revoir', style: AppTextStyles.headline3),
                              SizedBox(height: 4),
                              Text('Connectez-vous pour accéder à votre tableau de bord', style: AppTextStyles.body2),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email_outlined),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email requis';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: _loading
                                      ? null
                                      : () => setState(() {
                                            _obscure = !_obscure;
                                          }),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Mot de passe requis';
                                if (v.length < 8) return '8 caractères minimum';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _forgotPassword,
                                child: const Text('Mot de passe oublié ?'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _loading
                                ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                                : SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      child: const Text('Se connecter'),
                                    ),
                                  ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                        );
                                      },
                                child: const Text('Créer un compte'),
                              ),
                            ),
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
