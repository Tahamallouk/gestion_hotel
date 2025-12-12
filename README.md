# gestion_hotel

Application Flutter de gestion d'hôtel avec modules d'administration, de réservation et de statistiques.

## Pré-requis

- Flutter 3.24+ (channel stable)
- Dart 3.10+
- Un émulateur ou appareil iOS/Android pour les tests d'intégration

## Installation des dépendances

```bash
flutter pub get
```

## Qualité du code

- Analyse statique :

	```bash
	flutter analyze
	```

- Tests unitaires (avec mocks Firebase) :

	```bash
	flutter test --reporter=expanded
	```

## Tests d'intégration

Le dépôt contient un squelette `integration_test/driver.dart` compatible avec le `integration_test` package.

### Exécution locale

1. Démarrer un émulateur Android (`flutter emulators --launch <id>`) ou brancher un appareil.
2. Lancer les tests :

	 ```bash
	 flutter test integration_test
	 ```

3. Les tests supposent un projet Firebase configuré. Renseigner les fichiers `google-services.json` / `GoogleService-Info.plist` si nécessaire.

### CI (GitHub Actions)

- Utiliser une image `ubuntu-latest` ou `macos-latest`.
- Étapes recommandées :
	1. Installer Flutter (`subosito/flutter-action` ou `flutter-action`).
	2. `flutter pub get`
	3. `flutter analyze`
	4. `flutter test --reporter=expanded`
	5. (optionnel) `flutter test integration_test` avec des secrets Firebase (clé API, projet de test) et un émulateur Android via `reactivecircus/android-emulator-runner@v2`.

### Tests E2E réels

Pour exécuter des tests de bout en bout connectés à Firestore :

1. Créer un projet Firebase dédié aux tests.
2. Télécharger et placer les fichiers de configuration (`google-services.json`, `GoogleService-Info.plist`).
3. Autoriser les règles de sécurité adéquates ou utiliser l'émulateur Firebase (`firebase emulators:start --only firestore,auth`).
4. Lancer :

	 ```bash
	 flutter test integration_test
	 ```

Documenter toute configuration spécifique (identifiants de test, données seed) dans la documentation interne ou les workflows CI.
