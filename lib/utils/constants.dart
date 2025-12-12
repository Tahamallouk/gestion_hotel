// Global application constants
// Configuration values, feature flags, and configuration used across the app

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
const String currencySymbol = '€';
const String currencyCode = 'EUR';
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
