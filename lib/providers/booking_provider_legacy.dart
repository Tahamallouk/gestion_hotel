import 'package:flutter/foundation.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';

/// Provider pour gérer l'état des réservations avec ChangeNotifier
class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  
  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  /// Créer une nouvelle réservation
  Future<void> createReservation(Reservation reservation) async {
    _setLoading(true);
    _clearError();
    _setSuccess(false);
    
    try {
      await _firestore.createReservation(reservation);
      _setSuccess(true);
    } catch (e) {
      _setError('Erreur lors de la création de la réservation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Réinitialiser l'état
  void reset() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    notifyListeners();
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setSuccess(bool success) {
    _isSuccess = success;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}