import 'package:flutter/foundation.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';

/// Service sécurisé pour les opérations admin sur hotels et rooms
class AdminService {
  AdminService({AuthService? auth, FirestoreService? firestore})
      : _auth = auth ?? AuthService(),
        _firestore = firestore ?? FirestoreService();

  final AuthService _auth;
  final FirestoreService _firestore;

  /// Vérifie si l'utilisateur actuel est admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final role = await _firestore.getUserRole(user.uid);
      return role == 'admin';
    } catch (e) {
      debugPrint('Error checking admin role: $e');
      return false;
    }
  }

  /// Vérifier admin et lancer exception si pas admin
  Future<void> _ensureAdmin() async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Action non autorisée : Seuls les administrateurs peuvent effectuer cette opération');
    }
  }

  // =================== HOTELS CRUD ===================

  /// Créer un hôtel (Admin uniquement)
  Future<String> createHotel(Hotel hotel) async {
    await _ensureAdmin();
    
    try {
      // Ajouter timestamps
      final hotelWithTimestamp = hotel.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final hotelId = await _firestore.addHotel(hotelWithTimestamp);
      debugPrint('🏨 ADMIN created hotel: ${hotel.name} (ID: $hotelId)');
      return hotelId;
    } catch (e) {
      debugPrint('❌ ADMIN failed to create hotel: $e');
      rethrow;
    }
  }

  /// Lire la liste des hôtels (Admin uniquement)
  Future<List<Hotel>> getHotels() async {
    await _ensureAdmin();
    
    try {
      final hotels = await _firestore.getHotels();
      debugPrint('📖 ADMIN read ${hotels.length} hotels');
      return hotels;
    } catch (e) {
      debugPrint('❌ ADMIN failed to read hotels: $e');
      rethrow;
    }
  }

  /// Mettre à jour un hôtel (Admin uniquement)
  Future<void> updateHotel(String hotelId, Map<String, dynamic> data) async {
    await _ensureAdmin();
    
    try {
      // Ajouter updatedAt
      final dataWithTimestamp = {
        ...data,
        'updatedAt': DateTime.now(),
      };
      
      await _firestore.updateHotel(hotelId, dataWithTimestamp);
      debugPrint('🔄 ADMIN updated hotel: $hotelId');
    } catch (e) {
      debugPrint('❌ ADMIN failed to update hotel $hotelId: $e');
      rethrow;
    }
  }

  /// Supprimer un hôtel (Admin uniquement)
  Future<void> deleteHotel(String hotelId) async {
    await _ensureAdmin();
    
    try {
      await _firestore.deleteHotel(hotelId);
      debugPrint('🗑️ ADMIN deleted hotel: $hotelId (with cleanup)');
    } catch (e) {
      debugPrint('❌ ADMIN failed to delete hotel $hotelId: $e');
      rethrow;
    }
  }

  // =================== ROOMS CRUD ===================

  /// Créer une chambre (Admin uniquement)
  Future<String> createRoom(Room room) async {
    await _ensureAdmin();
    
    // Validation stricte du hotelId
    if (room.hotelId.isEmpty) {
      throw Exception('hotelId ne peut pas être vide');
    }
    
    // Vérifier que hotelId n'est pas mock
    if (room.hotelId.startsWith('mock-')) {
      throw Exception('Impossible de créer une chambre avec un hotelId mock: ${room.hotelId}');
    }
    
    try {
      // Debug de la sauvegarde
      debugPrint('🛏️ ADMIN création chambre - hotelId: ${room.hotelId}, numéro: ${room.number}');
      
      // Ajouter timestamps
      final roomWithTimestamp = room.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Vérifier une dernière fois avant Firestore
      final roomData = roomWithTimestamp.toMap();
      debugPrint('🔥 Données Firestore: ${roomData['hotelId']} -> chambre ${roomData['number']}');
      
      await _firestore.addRoom(roomWithTimestamp);
      debugPrint('✅ ADMIN chambre ${room.number} sauvegardée pour hôtel ${room.hotelId}');
      return room.hotelId; // Return something meaningful
    } catch (e) {
      debugPrint('❌ ADMIN failed to create room: $e');
      rethrow;
    }
  }

  /// Lire les chambres par hôtel (Admin uniquement)
  Stream<List<Room>> getRoomsByHotel(String hotelId) async* {
    await _ensureAdmin();
    
    if (hotelId.startsWith('mock-')) {
      debugPrint('⚠️ ADMIN attempted to read mock hotel rooms: $hotelId');
      yield [];
      return;
    }
    
    try {
      debugPrint('📖 ADMIN reading rooms for hotel: $hotelId');
      yield* _firestore.getRoomsByHotel(hotelId);
    } catch (e) {
      debugPrint('❌ ADMIN failed to read rooms for hotel $hotelId: $e');
      yield [];
    }
  }

  /// Mettre à jour une chambre (Admin uniquement)
  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _ensureAdmin();
    
    if (roomId.startsWith('mock-')) {
      throw Exception('Impossible de mettre à jour une chambre mock: $roomId');
    }
    
    try {
      // Ajouter updatedAt
      final dataWithTimestamp = {
        ...data,
        'updatedAt': DateTime.now(),
      };
      
      await _firestore.updateRoom(roomId, dataWithTimestamp);
      debugPrint('🔄 ADMIN updated room: $roomId');
    } catch (e) {
      debugPrint('❌ ADMIN failed to update room $roomId: $e');
      rethrow;
    }
  }

  /// Supprimer une chambre (Admin uniquement)
  Future<void> deleteRoom(String roomId) async {
    await _ensureAdmin();
    
    if (roomId.startsWith('mock-')) {
      throw Exception('Impossible de supprimer une chambre mock: $roomId');
    }
    
    try {
      await _firestore.deleteRoom(roomId);
      debugPrint('🗑️ ADMIN deleted room: $roomId');
    } catch (e) {
      debugPrint('❌ ADMIN failed to delete room $roomId: $e');
      rethrow;
    }
  }

  /// Obtenir une chambre spécifique (Admin uniquement)
  Future<Room?> getRoom(String roomId) async {
    await _ensureAdmin();
    
    if (roomId.startsWith('mock-')) {
      debugPrint('⚠️ ADMIN attempted to get mock room: $roomId');
      return null;
    }
    
    try {
      final rooms = await _firestore.getRooms();
      final room = rooms.where((r) => r.id == roomId).firstOrNull;
      debugPrint('📖 ADMIN read room: $roomId');
      return room;
    } catch (e) {
      debugPrint('❌ ADMIN failed to get room $roomId: $e');
      return null;
    }
  }
}