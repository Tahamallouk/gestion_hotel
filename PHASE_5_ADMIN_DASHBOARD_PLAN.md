# 🟦 PHASE 5 : Admin Dashboard — Plan Complet

**Date** : Décembre 2025  
**Statut** : En préparation  
**Objectif** : Créer un tableau de bord administrateur riche avec statistiques, graphiques et gestion centralisée.

---

## 📋 Table des matières

1. [Analyse des données requises](#1-analyse-des-données-requises)
2. [Architecture et structure des widgets](#2-architecture-et-structure-des-widgets)
3. [Méthodes FirestoreService](#3-méthodes-firestoreservice)
4. [Navigation et authentification](#4-navigation-et-authentification)
5. [Dépendances](#5-dépendances)
6. [Plan d'implémentation détaillé](#6-plan-dimplémentation-détaillé)
7. [Squelette UI (structure)](#7-squelette-ui-structure)

---

## 1. Analyse des données requises

### 🔢 Métriques principales

#### 1.1 Comptages simples
- **Nombre total d'hôtels** : Count de `hotels` collection
- **Nombre total de chambres** : Count de `rooms` collection
- **Nombre total de réservations** : Count de `reservations` collection

#### 1.2 Réservations par statut
- **Réservations confirmées** : Count WHERE `status == 'confirmed'`
- **Réservations annulées** : Count WHERE `status == 'cancelled'`
- **Réservations en attente** : Count WHERE `status == 'pending'`

#### 1.3 Taux d'occupation
```
Taux d'occupation = (Nombre de chambres non disponibles / Nombre total de chambres) * 100
```
- Query : Count WHERE `isAvailable == false`
- Source : Collection `rooms`
- Calcul: `(unavailable / total) * 100`

#### 1.4 Revenus estimés
```
Revenus = Σ(prix_chambre * nombre_jours) 
  pour chaque réservation WHERE status == 'confirmed'
```
- Nombre de jours = `(endDate - startDate).inDays`
- Prix de la chambre : Depuis la collection `rooms`
- Filtre : Uniquement les réservations confirmées (status == 'confirmed')

#### 1.5 Tendances
- **Hôtels les plus réservés** : Grouper réservations par `hotelId`, compter, trier DESC
- **Distribution par statut** : Comptage par `status` pour graphique pie/bar
- **Occupation par hôtel** : Par `hotelId`

---

## 2. Architecture et structure des widgets

### 2.1 Hiérarchie des fichiers

```
lib/
├── screens/
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart      (écran principal)
│   │   └── admin_menu_screen.dart           (navigation admin)
│   └── [existants]
├── widgets/
│   ├── stat_card.dart                       (petit widget métrique)
│   ├── chart_widget.dart                    (wrapper pour graphiques)
│   ├── occupancy_gauge.dart                 (jauge d'occupation)
│   └── [existants]
└── [existants]
```

### 2.2 Widgets à créer

#### `StatCard` — Petite carte avec icône + chiffre
```dart
class StatCard extends StatelessWidget {
  final String title;        // ex: "Total Hôtels"
  final String value;        // ex: "12"
  final IconData icon;       // ex: Icons.hotel
  final Color? color;        // couleur accentée
  final VoidCallback? onTap; // optionnel

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color ?? Colors.blue),
              SizedBox(height: 12),
              Text(title, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### `ChartWidget` — Wrapper pour afficher graphiques
```dart
// Utiliser fl_chart pour line/bar/pie charts
// Variantes :
//   - BarChartWidget(data: statsData)
//   - LineChartWidget(data: timeSeriesData)
//   - PieChartWidget(data: statusDistribution)
```

#### `OccupancyGauge` — Jauge circulaire ou linéaire
```dart
// Afficher taux d'occupation (%) avec jauge visuelle
// Utiliser: percent_indicator ou custom paint
```

### 2.3 Structure AdminDashboardScreen

L'écran sera composé de sections défilables (SingleChildScrollView) :

1. **Header** : Titre + bouton refresh
2. **Section 1 : Chiffres clés** (Grid 2x2)
   - Total hôtels
   - Total chambres
   - Total réservations
   - Taux d'occupation global

3. **Section 2 : Réservations par statut** (Grid 1x3)
   - Confirmées
   - Annulées
   - En attente

4. **Section 3 : Graphiques**
   - Distribution par statut (Pie chart)
   - Hôtels les plus réservés (Bar chart)

5. **Section 4 : Tendances**
   - Occupation par hôtel (Bar chart)
   - Revenus estimés (Line chart ou chiffre)

---

## 3. Méthodes FirestoreService

### 3.1 Comptages et statistiques

```dart
/// Nombre d'hôtels
Future<int> getHotelsCount() async {
  // Query: _db.collection('hotels').count().get()
  // Alternative: _db.collection('hotels').get().then((s) => s.docs.length)
}

/// Nombre de chambres
Future<int> getRoomsCount() async {
  // Query: _db.collection('rooms').count().get()
}

/// Nombre total de réservations
Future<int> getReservationsCount() async {
  // Query: _db.collection('reservations').count().get()
}

/// Nombre de réservations par statut
Future<Map<String, int>> getReservationsByStatus() async {
  // Retorner: {'confirmed': 15, 'cancelled': 5, 'pending': 3}
  // Logic: Pour chaque statut, compter WHERE status == statusValue
}

/// Nombre de chambres occupées (non disponibles)
Future<int> getOccupiedRoomsCount() async {
  // Query: _db.collection('rooms').where('isAvailable', isEqualTo: false).count().get()
}

/// Taux d'occupation (%)
Future<double> getOccupancyRate() async {
  // occupied = getOccupiedRoomsCount()
  // total = getRoomsCount()
  // return (occupied / total) * 100.0
}

/// Revenus estimés (confirmées uniquement)
Future<double> calculateEstimatedRevenue() async {
  // Fetch all confirmed reservations
  // Pour chaque : durée = (endDate - startDate).inDays
  // Récupérer price depuis rooms/{roomId}
  // Accumulate : Σ(prix * durée)
}

/// Hôtels les plus réservés
Future<List<Map<String, dynamic>>> getTopBookedHotels({int limit = 5}) async {
  // Retorner: [
  //   {'hotelId': '...', 'hotelName': '...', 'reservationCount': 15},
  //   ...
  // ]
}

/// Distribution des réservations par statut (pour graphique)
Future<List<ReservationStatusData>> getReservationStatusDistribution() async {
  // Retorner: [
  //   ReservationStatusData(status: 'confirmed', count: 15, color: Colors.green),
  //   ReservationStatusData(status: 'cancelled', count: 5, color: Colors.red),
  //   ReservationStatusData(status: 'pending', count: 3, color: Colors.amber),
  // ]
}

/// Occupation par hôtel
Future<List<HotelOccupancyData>> getOccupancyByHotel() async {
  // Retorner: [
  //   HotelOccupancyData(hotelId: '...', hotelName: '...', occupancyRate: 75.5),
  //   ...
  // ]
}
```

### 3.2 Models d'appui (helpers)

```dart
// À créer dans lib/models/

class ReservationStatusData {
  final String status;
  final int count;
  final Color color;

  ReservationStatusData({
    required this.status,
    required this.count,
    required this.color,
  });
}

class HotelOccupancyData {
  final String hotelId;
  final String hotelName;
  final double occupancyRate;
  final int totalRooms;
  final int occupiedRooms;

  HotelOccupancyData({
    required this.hotelId,
    required this.hotelName,
    required this.occupancyRate,
    required this.totalRooms,
    required this.occupiedRooms,
  });
}

class TopHotelData {
  final String hotelId;
  final String hotelName;
  final int reservationCount;

  TopHotelData({
    required this.hotelId,
    required this.hotelName,
    required this.reservationCount,
  });
}
```

---

## 4. Navigation et authentification

### 4.1 Accès au Dashboard

**Cas 1 : Depuis HomeScreen**
```dart
// Dans HomeScreen, si user.role == 'admin':
ElevatedButton.icon(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
  ),
  icon: Icon(Icons.dashboard),
  label: Text('Tableau de bord'),
)
```

**Cas 2 : Depuis un AdminMenuScreen (futur)**
```dart
// Créer AdminMenuScreen comme hub de navigation admin
// Options :
//   - Tableau de bord
//   - Gestion hôtels
//   - Gestion chambres
//   - Gestion réservations
//   - Paramètres admin
```

### 4.2 Authentification et rôles

- **Check admin** : `getUserRole(uid)` retourne `'admin'`
- **Gating** : Placer les boutons Admin derrière une condition `if (role == 'admin')`
- **Protection UI** : AdminDashboardScreen doit vérifier le rôle au montage et rediriger si non-admin

```dart
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final role = await _firestore.getUserRole(uid);
    if (mounted) {
      if (role != 'admin') {
        Navigator.pop(context);
      } else {
        setState(() => _userRole = role);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userRole != 'admin') {
      return const Scaffold(
        body: Center(child: Text('Accès refusé')),
      );
    }
    // Afficher le dashboard
    return _buildDashboard();
  }

  Widget _buildDashboard() {
    // Contenu ici
  }
}
```

---

## 5. Dépendances

### 5.1 Nouvelles dépendances à ajouter à `pubspec.yaml`

```yaml
dependencies:
  fl_chart: ^0.65.0              # Graphiques (bar, line, pie)
  percent_indicator: ^4.1.0      # Jauge de pourcentage
  intl: ^0.19.0                  # Déjà ajouté en Phase 4
```

### 5.2 Imports courants

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
```

---

## 6. Plan d'implémentation détaillé

### Phase 5a : Préparation (maintenant)
- [ ] Créer models d'appui (ReservationStatusData, HotelOccupancyData, TopHotelData)
- [ ] Ajouter dépendances (fl_chart, percent_indicator)
- [ ] Exécuter `flutter pub get`

### Phase 5b : Services et logique (Semaine 1)
- [ ] Implémenter toutes les méthodes dans FirestoreService
- [ ] Tester les méthodes (unit tests)
- [ ] Créer des modèles ViewModel ou utiliser FutureBuilder/StreamBuilder

### Phase 5c : Widgets (Semaine 1)
- [ ] Créer StatCard widget
- [ ] Créer ChartWidget (BarChart, LineChart, PieChart)
- [ ] Créer OccupancyGauge widget

### Phase 5d : AdminDashboardScreen (Semaine 2)
- [ ] Implémenter la structure de base
- [ ] Ajouter les sections (statistiques, graphiques, tendances)
- [ ] Ajouter rafraîchissement (refresh button)
- [ ] Ajouter gestion des erreurs et loading states

### Phase 5e : Navigation (Semaine 2)
- [ ] Mettre à jour HomeScreen pour ajouter bouton Admin
- [ ] Optionnel : Créer AdminMenuScreen
- [ ] Ajouter gating par rôle

### Phase 5f : Tests et polissage (Semaine 3)
- [ ] Tester l'intégration complète
- [ ] Ajuster les couleurs/designs
- [ ] Créer des tests intégration
- [ ] Optimiser les performances (cache, requêtes batch)

---

## 7. Squelette UI (structure)

### 7.1 Admin Dashboard Layout

```
┌─────────────────────────────────────────┐
│  Tableau de bord admin                  │ ↻ (refresh)
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────┬──────────────────┐ │
│  │  Total Hôtels    │  Total Chambres  │ │
│  │       12         │       156        │ │
│  └──────────────────┴──────────────────┘ │
│  ┌──────────────────┬──────────────────┐ │
│  │ Total Rés.       │  Taux Occup.     │ │
│  │      287         │      62.3%       │ │
│  └──────────────────┴──────────────────┘ │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Réservations par statut               │
│  ┌──────────────────┬──────────────────┐ │
│  │  Confirmées      │   Annulées      │ │
│  │       234        │        28        │ │
│  └──────────────────┴──────────────────┘ │
│  ┌──────────────────┐                   │
│  │   En attente     │                   │
│  │        25        │                   │
│  └──────────────────┘                   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Distribution des réservations         │
│  ┌──────────────────────────────────────┐│
│  │      [PieChart]                      ││
│  │   Confirmées: 81%                    ││
│  │   Annulées: 10%                      ││
│  │   Attente: 9%                        ││
│  └──────────────────────────────────────┘│
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Hôtels les plus réservés              │
│  ┌──────────────────────────────────────┐│
│  │      [BarChart]                      ││
│  │  Hotel A: ███████ 45 réservations    ││
│  │  Hotel B: █████ 32 réservations      ││
│  │  Hotel C: ████ 28 réservations       ││
│  └──────────────────────────────────────┘│
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Occupation par hôtel                  │
│  ┌──────────────────────────────────────┐│
│  │      [BarChart]                      ││
│  │  Hotel A: ███████ 78%                ││
│  │  Hotel B: █████ 65%                  ││
│  │  Hotel C: ███████████ 92%            ││
│  └──────────────────────────────────────┘│
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Revenus estimés (confirmées)          │
│  ┌──────────────────────────────────────┐│
│  │  Total: 45,250 €                     ││
│  │  [LineChart de tendance]             ││
│  └──────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

### 7.2 AdminMenuScreen (optionnel - futur)

```
┌─────────────────────────────────────────┐
│  Menu Administration                    │
├─────────────────────────────────────────┤
│                                         │
│  [ 📊 Tableau de bord ]                │
│  [ 🏨 Gestion des hôtels ]             │
│  [ 🛏️  Gestion des chambres ]          │
│  [ 📅 Gestion des réservations ]       │
│  [ 👥 Gestion des utilisateurs ]       │
│  [ ⚙️  Paramètres Admin ]              │
│  [ 🚪 Déconnexion ]                    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 8. Résumé des fichiers à créer/modifier

### Nouveaux fichiers

| Chemin | Type | Description |
|--------|------|-------------|
| `lib/screens/admin/admin_dashboard_screen.dart` | Screen | Écran principal du dashboard |
| `lib/screens/admin/admin_menu_screen.dart` | Screen | Menu de navigation admin (optionnel) |
| `lib/widgets/stat_card.dart` | Widget | Petite carte de statistique |
| `lib/widgets/chart_widget.dart` | Widget | Wrapper pour graphiques |
| `lib/widgets/occupancy_gauge.dart` | Widget | Jauge d'occupation |
| `lib/models/admin_statistics.dart` | Model | ReservationStatusData, HotelOccupancyData, TopHotelData |

### Fichiers à modifier

| Chemin | Modification |
|--------|-------------|
| `lib/services/firestore_service.dart` | Ajouter toutes les méthodes de statistiques |
| `lib/screens/home/home_screen.dart` | Ajouter bouton Admin Dashboard (avec gating) |
| `pubspec.yaml` | Ajouter fl_chart et percent_indicator |

---

## 9. Points clés de sécurité et optimisation

### 9.1 Sécurité
- ✅ Vérifier le rôle admin avant d'afficher le dashboard
- ✅ Utiliser Firestore Rules pour restreindre l'accès aux statistiques (côté serveur)
- ✅ Logger les accès admin pour audit

### 9.2 Optimisation des requêtes
- ✅ Utiliser `.count().get()` au lieu de récupérer tous les documents
- ✅ Implémenter un cache local (ex: StreamBuilder + debounce)
- ✅ Batch les requêtes statistiques pour éviter trop d'appels parallèles

### 9.3 Performance UI
- ✅ Utiliser SingleChildScrollView pour éviter les overflow
- ✅ Lazy-load les graphiques complexes
- ✅ Implémenter un bouton refresh plutôt que auto-refresh

---

## 10. Timeline estimée

| Phase | Durée | Tâches |
|-------|-------|--------|
| 5a | 1h | Créer models, ajouter dépendances |
| 5b | 4h | Implémenter FirestoreService, tests |
| 5c | 3h | Créer widgets (StatCard, Charts, Gauge) |
| 5d | 4h | Implémenter AdminDashboardScreen |
| 5e | 2h | Navigation, gating, liens |
| 5f | 3h | Tests, polissage, optimisations |
| **Total** | **~17h** | Fin Phase 5 |

---

## Next Steps

1. ✅ **Valider ce plan** avec l'utilisateur
2. ⏳ **Ajouter les dépendances** (fl_chart, percent_indicator)
3. ⏳ **Créer les models d'appui**
4. ⏳ **Implémenter les méthodes FirestoreService**
5. ⏳ **Créer les widgets**
6. ⏳ **Construire AdminDashboardScreen**
7. ⏳ **Intégrer la navigation**
8. ⏳ **Tester et déployer**

---

**Fin du plan Phase 5 Admin Dashboard**
