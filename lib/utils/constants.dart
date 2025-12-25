// Global application constants
// Configuration values, feature flags, and configuration used across the app

import 'package:flutter/material.dart';

// ============ API & NETWORK ============
const String firebaseProjectId = 'gestion-hotel-dev';
const Duration apiTimeout = Duration(seconds: 30);
const Duration connectionTimeout = Duration(seconds: 15);

// ============ CACHE ============
const Duration cacheTokenDuration = Duration(minutes: 30);
const Duration cacheDashboardDuration = Duration(minutes: 15);
const Duration cacheHotelsDuration = Duration(minutes: 30);
const Duration cacheUserDuration = Duration(minutes: 60);

// ============ PAGINATION ============
const int paginationPageSize = 10;
const int paginationInitialPages = 1;
const int maxPaginationPages = 100;

// ============ DEBOUNCE ============
const Duration debounceSearchDuration = Duration(milliseconds: 500);
const Duration debounceFilterDuration = Duration(milliseconds: 300);

// ============ ANIMATIONS ============
const Duration animationDuration = Duration(milliseconds: 300);
const Duration animationDurationShort = Duration(milliseconds: 150);
const Duration animationDurationLong = Duration(milliseconds: 500);
const Duration animationDurationXLong = Duration(milliseconds: 800);
const Curve defaultCurve = Curves.easeInOut;
const Curve bounceOutCurve = Curves.elasticOut;
const Curve fastCurve = Curves.easeOut;

// ============ VALIDATION ============
const int minPasswordLength = 8;
const int maxPasswordLength = 128;
const int minNameLength = 2;
const int maxNameLength = 100;
const int maxPhoneLength = 20;
const int maxAddressLength = 255;

// ============ USER ROLES ============
const String roleAdmin = 'admin';
const String roleManager = 'manager';
const String roleGuest = 'guest';
const String roleUser = 'user';

// ============ STATUS VALUES ============
const String statusConfirmed = 'confirmed';
const String statusPending = 'pending';
const String statusCancelled = 'cancelled';

// ============ ROOM STATUS ============
const String roomAvailable = 'available';
const String roomOccupied = 'occupied';
const String roomMaintenance = 'maintenance';

// ============ ERROR MESSAGES ============
const String errorNetworkFailure = 'Erreur réseau. Vérifiez votre connexion.';
const String errorInvalidEmail = 'Email invalide.';
const String errorWeakPassword = 'Le mot de passe est trop faible.';
const String errorUserNotFound = 'Utilisateur non trouvé.';
const String errorInvalidCredentials = 'Email ou mot de passe incorrect.';
const String errorUserAlreadyExists = 'Cet email est déjà utilisé.';
const String errorUnknown = 'Une erreur inconnue s\'est produite.';
const String errorServerError = 'Erreur serveur. Réessayez plus tard.';
const String errorTimeout = 'La requête a expiré. Réessayez.';

// ============ SUCCESS MESSAGES ============
const String successLogin = 'Connexion réussie!';
const String successLogout = 'Déconnexion réussie!';
const String successPasswordReset = 'Email de réinitialisation envoyé.';
const String successReservationCreated = 'Réservation créée avec succès!';
const String successReservationCancelled = 'Réservation annulée.';
const String successDataSaved = 'Données sauvegardées.';
const String successDataDeleted = 'Données supprimées.';
const String successExported = 'Données exportées avec succès!';

// ============ ROUTES ============
const String routeHome = '/';
const String routeLogin = '/login';
const String routeSignup = '/signup';
const String routeForgotPassword = '/forgot-password';
const String routeHotelList = '/hotels';
const String routeHotelDetail = '/hotels/:id';
const String routeRoomList = '/rooms';
const String routeRoomDetail = '/rooms/:id';
const String routeReservationList = '/reservations';
const String routeReservationCreate = '/reservations/create';
const String routeAdminDashboard = '/admin';
const String routeAdminHotels = '/admin/hotels';
const String routeAdminHotelDetail = '/admin/hotels/:id';
const String routeAdminReservations = '/admin/reservations';
const String routeAdminRooms = '/admin/rooms';

// ============ DATABASE COLLECTIONS ============
const String collectionUsers = 'users';
const String collectionHotels = 'hotels';
const String collectionRooms = 'rooms';
const String collectionReservations = 'reservations';
const String collectionPayments = 'payments';
const String collectionReviews = 'reviews';

// ============ FIRESTORE FIELDS ============
const String fieldId = 'id';

// ============ RESPONSIVE BREAKPOINTS ============
class ResponsiveBreakpoints {
  /// Mobile: < 600px
  static const double mobile = 600;
  
  /// Tablet: 600px - 1024px
  static const double tablet = 1024;
  
  /// Desktop: > 1024px
  static const double desktop = 1200;
  
  /// Large desktop: > 1600px
  static const double largeDesktop = 1600;
}

// ============ SHADOW ELEVATIONS ============
class AppShadows {
  /// Subtle shadow for cards
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  
  /// Standard shadow for lifted elements
  static const List<BoxShadow> standard = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Medium shadow for modals
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  
  /// High shadow for floating elements
  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Maximum shadow for FAB & overlays
  static const List<BoxShadow> maximum = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}

// ============ ICON SIZES ============
class AppIconSizes {
  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 40;
  static const double xxl = 48;
  static const double xxxl = 56;
}

// ============ AVATAR SIZES ============
class AppAvatarSizes {
  static const double sm = 32;
  static const double md = 48;
  static const double lg = 64;
  static const double xl = 80;
}

// ============ CARD SIZES ============
class AppCardSizes {
  static const double minHeight = 80;
  static const double standardHeight = 120;
  static const double tallHeight = 160;
  static const double minWidth = 100;
}

// ============ CHART & GRAPH SIZES ============
class AppChartSizes {
  static const double chartHeight = 300;
  static const double chartHeightCompact = 200;
  static const double gaugeSize = 200;
  static const double gaugeCompactSize = 120;
}

// ============ DIALOG & MODAL SIZES ============
class AppModalSizes {
  static const double dialogMinWidth = 280;
  static const double dialogMaxWidth = 500;
  static const double bottomSheetMinHeight = 200;
}

// ============ LINE HEIGHTS & LETTER SPACING ============
class AppLineHeights {
  static const double tight = 1.2;
  static const double normal = 1.4;
  static const double relaxed = 1.6;
  static const double spacious = 1.8;
}

class AppLetterSpacing {
  static const double tight = -0.5;
  static const double normal = 0;
  static const double loose = 0.15;
  static const double extraLoose = 0.5;
}

// ============ OPACITY VALUES ============
class AppOpacity {
  static const double disabled = 0.38;
  static const double hoverLight = 0.08;
  static const double hoverDark = 0.12;
  static const double focusLight = 0.12;
  static const double focusDark = 0.16;
}

// ============ DURATION PRESETS ============
class AppDurations {
  /// Very quick animations (150ms)
  static const Duration quick = Duration(milliseconds: 150);
  
  /// Standard animations (300ms)
  static const Duration standard = Duration(milliseconds: 300);
  
  /// Slow animations (500ms)
  static const Duration slow = Duration(milliseconds: 500);
  
  /// Very slow animations (800ms)
  static const Duration verySlow = Duration(milliseconds: 800);
  
  /// Extended animations (1200ms)
  static const Duration extended = Duration(milliseconds: 1200);
  
  /// Page transitions (400ms)
  static const Duration pageTransition = Duration(milliseconds: 400);
  
  /// Loading spinner (2000ms)
  static const Duration loadingSpinner = Duration(milliseconds: 2000);
}

// ============ GRADIENT PRESETS ============
class AppGradients {
  /// Primary gradient (Blue to Cyan)
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
  );
  
  /// Success gradient (Green to Teal)
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF009688)],
  );
  
  /// Error gradient (Red to Orange)
  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFFB8C00)],
  );
  
  /// Warning gradient (Orange to Amber)
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB8C00), Color(0xFFFFC107)],
  );
}

// ============ Z-INDEX LAYERS ============
class AppLayers {
  static const int ground = 0;
  static const int surface = 100;
  static const int floating = 500;
  static const int modal = 1000;
  static const int overlay = 2000;
}

// ============ PLATFORM SPECIFIC ============
const bool isAndroid = true;
const bool isIOS = false;
const String fieldEmail = 'email';
const String fieldFirstName = 'firstName';
const String fieldLastName = 'lastName';
const String fieldPhoneNumber = 'phoneNumber';
const String fieldRole = 'role';
const String fieldCreatedAt = 'createdAt';
const String fieldUpdatedAt = 'updatedAt';
const String fieldStatus = 'status';
const String fieldName = 'name';
const String fieldAddress = 'address';
const String fieldCity = 'city';
const String fieldCountry = 'country';
const String fieldRating = 'rating';
const String fieldImageUrl = 'imageUrl';
const String fieldCheckInDate = 'checkInDate';
const String fieldCheckOutDate = 'checkOutDate';
const String fieldPrice = 'price';
const String fieldTotalPrice = 'totalPrice';
const String fieldGuests = 'guests';
const String fieldIsAvailable = 'isAvailable';

// ============ APP INFO ============
const String appName = 'Gestion Hôtel';
const String appVersion = '1.0.0';
const String appBuild = '1';
const String supportEmail = 'support@gestionhotel.com';
const String privacyPolicyUrl = 'https://gestionhotel.com/privacy';
const String termsOfServiceUrl = 'https://gestionhotel.com/terms';

// ============ FEATURE FLAGS ============
const bool enableDarkMode = true;
const bool enablePushNotifications = true;
const bool enableFavorites = true;
const bool enableExport = true;
const bool enableOfflineMode = false; // Phase 5c
const bool enableAnalytics = true;
const bool enableCrashReporting = true;

// ============ UI LIMITS ============
const int maxHotelsDisplayed = 50;
const int maxRoomsDisplayed = 100;
const int maxReservationsDisplayed = 100;
const int maxCharactersName = 100;
const int maxCharactersDescription = 500;
const int maxCharactersEmail = 254;

// ============ DATE FORMAT ============
const String dateFormatShort = 'dd/MM/yyyy';
const String dateFormatFull = 'EEEE d MMMM yyyy';
const String timeFormatShort = 'HH:mm';
const String dateTimeFormatShort = 'dd/MM/yyyy HH:mm';

// ============ CURRENCY ============
const String currencySymbol = 'DH';
const String currencyCode = 'MAD';
const int currencyDecimalPlaces = 2;

// ============ LOCATION ============
const String defaultCountry = 'France';
const String defaultLanguage = 'fr';
const String defaultTimeZone = 'Europe/Paris';

// ============ FILE SIZES ============
const int maxFileSize = 10 * 1024 * 1024; // 10 MB
const int maxImageSize = 5 * 1024 * 1024; // 5 MB
const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];

// ============ RATING ============
const double minRating = 0.0;
const double maxRating = 5.0;
const int minReviewsForRating = 5;

// ============ PRICE ============
const double minRoomPrice = 10.0;
const double maxRoomPrice = 10000.0;
const int minStayDays = 1;
const int maxStayDays = 365;

// ============ OCCUPANCY ============
const int minRoomCapacity = 1;
const int maxRoomCapacity = 10;

// ============ ADMIN DASHBOARD ============
const int adminDashboardRefreshIntervalSeconds = 30;
const List<int> timeRangeFilterOptions = [7, 30, 90];

// ============ SHARED PREFERENCES KEYS ============
const String spKeyAuthToken = 'auth_token';
const String spKeyUserRole = 'user_role';
const String spKeyUserId = 'user_id';
const String spKeyUserEmail = 'user_email';
const String spKeyUserFirstName = 'user_first_name';
const String spKeyLastTimeRange = 'last_time_range';
const String spKeyDarkModeEnabled = 'dark_mode_enabled';
const String spKeyLanguage = 'language';
const String spKeyFavoriteHotels = 'favorite_hotels';
const String spKeyLastHomeScroll = 'last_home_scroll';
const String spKeyLastHotelsScroll = 'last_hotels_scroll';

// ============ LOGGING ============
const bool enableVerboseLogging = true;
const bool enableNetworkLogging = false; // Security: disable in prod
const int logMaxLines = 1000;

// ============ TESTING ============
const bool runIntegrationTests = true;
const bool runWidgetTests = true;
const bool mockFirebase = false;
