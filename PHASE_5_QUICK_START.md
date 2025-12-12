# Phase 5 : Admin Dashboard — Instructions de démarrage rapide

**Date** : Décembre 12, 2025  
**Prochaine étape** : Phase 5b - Implémentation des graphiques

---

## 🚀 Avant de commencer Phase 5b

### Étape 1 : Installer les dépendances

```bash
cd c:\gestion_hotel
flutter pub get
```

**Résultat attendu** :
```
Running "flutter pub get" in gestion_hotel...
Resolving dependencies...
+ fl_chart 0.65.0
+ percent_indicator 4.1.0
[autres dépendances...]
Got dependencies in X seconds
```

---

### Étape 2 : Vérifier la compilation

```bash
flutter analyze
```

**Résultat attendu** : Pas d'erreur critique (quelques warnings/info OK)

---

### Étape 3 : Tester l'accès au Dashboard

1. **Lancer l'app** :
```bash
flutter run -d chrome
```

2. **Se connecter en tant qu'admin** :
   - Email : un compte avec `role == 'admin'` dans Firestore
   - Vérifier dans `users/{uid}` que `role` field existe et = "admin"

3. **Vérifier que le bouton apparaît** :
   - HomeScreen doit avoir un bouton "Tableau de bord admin" (orange)
   - Cliquer → AdminDashboardScreen charge

4. **Vérifier les statistiques** :
   - Les 4 cartes du haut doivent afficher des nombres
   - Les 3 cartes de statut doivent remplir
   - La jauge doit afficher un taux

---

## 📋 Fichiers qui ont changé

### Créés (12 fichiers)
```
lib/models/admin_statistics.dart
lib/screens/admin/admin_dashboard_screen.dart
lib/screens/admin/admin_menu_screen.dart
lib/widgets/stat_card.dart
lib/widgets/chart_container.dart
lib/widgets/occupancy_gauge.dart
PHASE_5_ADMIN_DASHBOARD_PLAN.md
PHASE_5_PREP_SUMMARY.md
integration_test/app_test.dart (modifié)
```

### Modifiés (2 fichiers)
```
lib/services/firestore_service.dart          (+9 méthodes)
lib/screens/home/home_screen.dart            (+import, +buttons)
pubspec.yaml                                 (+2 dépendances)
```

---

## 🎯 Phase 5b : Checklist d'implémentation

### Étape 1 : Graphiques
- [ ] Importer `fl_chart`
- [ ] Remplacer PieChart placeholder
- [ ] Remplacer BarChart (hôtels)
- [ ] Remplacer BarChart (occupation)

### Étape 2 : Features
- [ ] Ajouter TimeRange filter (optionnel)
- [ ] Implémenter cache local
- [ ] Ajouter animations

### Étape 3 : Polissage
- [ ] Tests intégration
- [ ] Optimiser performances
- [ ] Ajuster couleurs/designs

---

## 🔥 Code snippets rapides

### Comment ajouter un PieChart

```dart
import 'package:fl_chart/fl_chart.dart';

// Dans AdminDashboardScreen._buildDashboard()
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(
        value: _confirmedCount.toDouble(),
        title: 'Confirmées (${_confirmedCount})',
        color: Colors.green,
        radius: 80,
      ),
      // ... autres sections
    ],
  ),
)
```

### Comment utiliser OccupancyGauge

```dart
OccupancyGauge(
  occupancyRate: _occupancyRate,    // 0-100
  label: 'Occupation',
  size: 180,
)
```

### Comment récupérer les données

```dart
// Dans _loadAllStatistics():
final stats = DashboardStats(
  totalHotels: await _firestore.getHotelsCount(),
  totalRooms: await _firestore.getRoomsCount(),
  // ... etc
);
```

---

## 🐛 Troubleshooting

### "Widget not found" error
→ Vérifier les imports dans `admin_dashboard_screen.dart`

### Statistiques vides / toujours "Loading"
→ Vérifier que Firestore est connecté et contient des données

### Admin button n'apparaît pas
→ Vérifier que l'utilisateur a `role: 'admin'` dans Firestore users/{uid}

### Chart error "fl_chart not found"
→ Exécuter `flutter pub get` puis `flutter pub upgrade`

---

## 📚 Références

- **Plan complet** : `PHASE_5_ADMIN_DASHBOARD_PLAN.md`
- **Résumé prép** : `PHASE_5_PREP_SUMMARY.md`
- **FlChart docs** : https://github.com/imaNNeoFighT/fl_chart
- **PercentIndicator** : https://pub.dev/packages/percent_indicator

---

## ✅ Validation

Avant de merger Phase 5b :

- [ ] Tous les graphiques affichent
- [ ] Statistiques se rechargent au refresh
- [ ] Admin gating fonctionne (non-admin voir message)
- [ ] Aucun warning bloquant dans `flutter analyze`
- [ ] Tests passent : `flutter test`
- [ ] UI responsive (mobile + tablet)

---

**Vous êtes prêt pour Phase 5b ! 🎉**
