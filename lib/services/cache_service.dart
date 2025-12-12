import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_hotel/utils/constants.dart';

/// Service for caching data locally using SharedPreferences
/// Provides convenient methods for storing and retrieving user preferences,
/// auth tokens, and other cacheable data
class CacheService {
  static final CacheService _instance = CacheService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  /// Initialize the cache service
  /// Must be called once at app startup
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    debugLog('[CacheService] Initialized');
  }

  /// Ensure initialized before accessing
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('CacheService not initialized. Call initialize() first.');
    }
  }

  // ============ AUTH TOKEN ============

  /// Save authentication token with expiration
  Future<void> setAuthToken(String token) async {
    _ensureInitialized();
    await _prefs.setString(spKeyAuthToken, token);
    debugLog('[CacheService] Auth token saved');
  }

  /// Get cached auth token
  String? getAuthToken() {
    _ensureInitialized();
    return _prefs.getString(spKeyAuthToken);
  }

  /// Remove auth token
  Future<void> clearAuthToken() async {
    _ensureInitialized();
    await _prefs.remove(spKeyAuthToken);
    debugLog('[CacheService] Auth token cleared');
  }

  // ============ USER INFO ============

  /// Save user ID
  Future<void> setUserId(String userId) async {
    _ensureInitialized();
    await _prefs.setString(spKeyUserId, userId);
  }

  /// Get cached user ID
  String? getUserId() {
    _ensureInitialized();
    return _prefs.getString(spKeyUserId);
  }

  /// Save user email
  Future<void> setUserEmail(String email) async {
    _ensureInitialized();
    await _prefs.setString(spKeyUserEmail, email);
  }

  /// Get cached user email
  String? getUserEmail() {
    _ensureInitialized();
    return _prefs.getString(spKeyUserEmail);
  }

  /// Save user role
  Future<void> setUserRole(String role) async {
    _ensureInitialized();
    await _prefs.setString(spKeyUserRole, role);
  }

  /// Get cached user role
  String? getUserRole() {
    _ensureInitialized();
    return _prefs.getString(spKeyUserRole);
  }

  /// Save user first name
  Future<void> setUserFirstName(String firstName) async {
    _ensureInitialized();
    await _prefs.setString(spKeyUserFirstName, firstName);
  }

  /// Get cached user first name
  String? getUserFirstName() {
    _ensureInitialized();
    return _prefs.getString(spKeyUserFirstName);
  }

  /// Clear all user info
  Future<void> clearUserInfo() async {
    _ensureInitialized();
    await Future.wait([
      _prefs.remove(spKeyUserId),
      _prefs.remove(spKeyUserEmail),
      _prefs.remove(spKeyUserRole),
      _prefs.remove(spKeyUserFirstName),
    ]);
    debugLog('[CacheService] User info cleared');
  }

  // ============ PREFERENCES ============

  /// Save last selected time range for dashboard (7, 30, or 90)
  Future<void> setLastTimeRange(int days) async {
    _ensureInitialized();
    await _prefs.setInt(spKeyLastTimeRange, days);
  }

  /// Get last selected time range (default 30)
  int getLastTimeRange() {
    _ensureInitialized();
    return _prefs.getInt(spKeyLastTimeRange) ?? 30;
  }

  /// Save dark mode preference
  Future<void> setDarkModeEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs.setBool(spKeyDarkModeEnabled, enabled);
  }

  /// Get dark mode preference
  bool isDarkModeEnabled() {
    _ensureInitialized();
    return _prefs.getBool(spKeyDarkModeEnabled) ?? false;
  }

  /// Save language preference
  Future<void> setLanguage(String language) async {
    _ensureInitialized();
    await _prefs.setString(spKeyLanguage, language);
  }

  /// Get language preference (default 'fr')
  String getLanguage() {
    _ensureInitialized();
    return _prefs.getString(spKeyLanguage) ?? 'fr';
  }

  // ============ FAVORITES ============

  /// Add hotel to favorites
  Future<void> addFavoriteHotel(String hotelId) async {
    _ensureInitialized();
    final favorites = getFavoriteHotels();
    if (!favorites.contains(hotelId)) {
      favorites.add(hotelId);
      await _prefs.setStringList(spKeyFavoriteHotels, favorites);
      debugLog('[CacheService] Added favorite hotel: $hotelId');
    }
  }

  /// Remove hotel from favorites
  Future<void> removeFavoriteHotel(String hotelId) async {
    _ensureInitialized();
    final favorites = getFavoriteHotels();
    favorites.remove(hotelId);
    await _prefs.setStringList(spKeyFavoriteHotels, favorites);
    debugLog('[CacheService] Removed favorite hotel: $hotelId');
  }

  /// Get all favorite hotels
  List<String> getFavoriteHotels() {
    _ensureInitialized();
    return _prefs.getStringList(spKeyFavoriteHotels) ?? [];
  }

  /// Check if hotel is favorited
  bool isFavoriteHotel(String hotelId) {
    _ensureInitialized();
    return getFavoriteHotels().contains(hotelId);
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    _ensureInitialized();
    await _prefs.remove(spKeyFavoriteHotels);
    debugPrint('[CacheService] Favorites cleared');
  }

  // ============ SCROLL POSITIONS ============

  /// Save scroll position for home screen
  Future<void> setLastHomeScroll(double position) async {
    _ensureInitialized();
    await _prefs.setDouble(spKeyLastHomeScroll, position);
  }

  /// Get last scroll position for home screen
  double getLastHomeScroll() {
    _ensureInitialized();
    return _prefs.getDouble(spKeyLastHomeScroll) ?? 0.0;
  }

  /// Save scroll position for hotels list
  Future<void> setLastHotelsScroll(double position) async {
    _ensureInitialized();
    await _prefs.setDouble(spKeyLastHotelsScroll, position);
  }

  /// Get last scroll position for hotels list
  double getLastHotelsScroll() {
    _ensureInitialized();
    return _prefs.getDouble(spKeyLastHotelsScroll) ?? 0.0;
  }

  // ============ GENERIC METHODS ============

  /// Set string value
  Future<void> setString(String key, String value) async {
    _ensureInitialized();
    await _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    _ensureInitialized();
    return _prefs.getString(key);
  }

  /// Set integer value
  Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    await _prefs.setInt(key, value);
  }

  /// Get integer value
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs.getInt(key);
  }

  /// Set boolean value
  Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    await _prefs.setBool(key, value);
  }

  /// Get boolean value
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs.getBool(key);
  }

  /// Set double value
  Future<void> setDouble(String key, double value) async {
    _ensureInitialized();
    await _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs.getDouble(key);
  }

  /// Remove key
  Future<void> remove(String key) async {
    _ensureInitialized();
    await _prefs.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs.containsKey(key);
  }

  /// Clear all cached data
  Future<void> clear() async {
    _ensureInitialized();
    await _prefs.clear();
    debugLog('[CacheService] All cache cleared');
  }

  /// Get all keys
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs.getKeys();
  }
}

// Helper function for debugging
void debugLog(String message) {
  if (enableVerboseLogging) {
    debugPrint(message);
  }
}
