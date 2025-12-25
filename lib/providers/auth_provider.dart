import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_hotel/services/auth_service.dart';

/// Provider pour gérer l'état d'authentification avec ChangeNotifier
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Écouter les changements d'état d'authentification
    _authService.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
    
    // Définir l'utilisateur actuel
    _currentUser = _authService.currentUser;
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signInWithEmail(email, password);
    } catch (e) {
      _setError('Erreur de connexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _setError('Erreur de déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}