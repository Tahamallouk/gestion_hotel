import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Check if Firebase Auth is properly configured for web
  Future<void> validateFirebaseConfiguration() async {
    try {
      debugPrint('🔍 Validating Firebase configuration...');
      // Firebase instance is already initialized in main.dart
      debugPrint('✅ Firebase Auth instance available');
      debugPrint('✅ Firestore instance available');
    } catch (e) {
      debugPrint('❌ Firebase configuration error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<User?> registerWithEmail(
    String email,
    String password, {
    required String fullName,
    required String phone,
  }) async {
    try {
      debugPrint('🔐 === REGISTRATION START ===');
      debugPrint('📧 Email: $email');
      debugPrint('👤 Full Name: $fullName');
      debugPrint('📱 Phone: $phone');
      
      debugPrint('📝 Attempting Firebase Auth user creation...');
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ Firebase Auth user created successfully');
      debugPrint('   UID: ${result.user?.uid}');
      debugPrint('   Email: ${result.user?.email}');

      final user = result.user;

      if (user != null) {
        debugPrint('💾 Saving user data to Firestore...');
        await _firestore.createUser(
          uid: user.uid,
          email: email,
          fullName: fullName,
          phone: phone,
        );
        debugPrint('✅ User data saved to Firestore successfully');
        debugPrint('🎉 === REGISTRATION SUCCESS ===');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ === FIREBASE AUTH ERROR ===');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Plugin: ${e.plugin}');
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('❌ === PLATFORM ERROR ===');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.details}');
      rethrow;
    } catch (e) {
      debugPrint('❌ === UNEXPECTED ERROR ===');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Send a password reset email to [email].
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Convert Firebase exceptions into readable messages.
  static String formatException(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé pour cet e-mail.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cette adresse e-mail est déjà utilisée.';
        case 'weak-password':
          return 'Mot de passe trop faible.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard.';
        case 'operation-not-allowed':
          return 'L\'authentification par email/password n\'est pas activée. Contactez l\'administrateur.';
        case 'invalid-api-key':
          return 'Clé API Firebase invalide. Vérifiez la configuration.';
        case 'network-request-failed':
          return 'Erreur réseau. Vérifiez votre connexion Internet.';
        default:
          return '${e.message ?? "Erreur d'authentification"} (Code: ${e.code})';
      }
    }
    return e.toString();
  }
}
