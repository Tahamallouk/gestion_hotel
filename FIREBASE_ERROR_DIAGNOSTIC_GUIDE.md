# Guide de Diagnostic des Erreurs Firebase - Enregistrement Web

## Étape 1: Accéder à la Console du Navigateur
1. Ouvrez l'application Flutter dans Chrome (http://localhost:xxxx)
2. Appuyez sur **F12** ou **Ctrl+Shift+I** pour ouvrir les Developer Tools
3. Cliquez sur l'onglet **Console** en haut

## Étape 2: Nettoyer la Console
- Cliquez sur le bouton **Effacer** (en haut à gauche de la Console)
- Cela évite de voir les anciens messages

## Étape 3: Remplir le Formulaire d'Inscription
Dans l'application, remplissez le formulaire avec:
- **Email**: test@example.com (ou n'importe quel email)
- **Nom complet**: Test User
- **Téléphone**: +212612345678 (ou n'importe quel numéro)
- **Mot de passe**: password123 (minimum 6 caractères)

Cliquez sur le bouton **S'inscrire**

## Étape 4: Identifier les Logs d'Erreur
Regardez la Console pour trouver les messages qui commencent par:
- ❌ === FIREBASE AUTH ERROR ===
- ❌ === PLATFORM ERROR ===
- ❌ === UNEXPECTED ERROR ===

## Étape 5: Copier les Informations d'Erreur
Reportez exactement:
1. **Le code d'erreur** (après "Code:")
   - Exemples: operation-not-allowed, invalid-api-key, email-already-in-use, etc.

2. **Le message d'erreur** (après "Message:")
   - Le texte complet du message

3. **Les détails supplémentaires** (s'il y a):
   - Tout ce qui est affiché après "Details:" ou "Plugin:"

## Exemple de Format à Copier:
```
❌ === FIREBASE AUTH ERROR ===
   Code: operation-not-allowed
   Message: Password sign-in is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Authentication section.
   Plugin: firebase_auth
```

## Étape 6: Vérifications Supplémentaires

### Si vous voyez "Invalid API Key":
- Allez à: https://console.firebase.google.com
- Projet: gestion-hotel-app-taham5439
- Paramètres → Clés API (Google Cloud Console)
- Vérifiez que la clé API web n'a pas de restrictions

### Si vous voyez "Operation Not Allowed":
- Allez à: https://console.firebase.google.com
- Projet: gestion-hotel-app-taham5439
- Authentification → Méthode de connexion
- Vérifiez que "Email/Password" est **ACTIVÉ**

### Si vous voyez "HTTP 400":
- Ouvrez l'onglet **Network** dans les Developer Tools
- Rechargez la page (F5)
- Tentez à nouveau l'inscription
- Recherchez les requêtes vers "identitytoolkit.googleapis.com"
- Cliquez dessus et regardez l'onglet **Response** pour plus de détails

## Logs Affichés à Chaque Étape (Succès)
Si l'inscription réussit, vous verrez:
```
🔐 === REGISTRATION START ===
📧 Email: test@example.com
👤 Full Name: Test User
📱 Phone: +212612345678
📝 Attempting Firebase Auth user creation...
✅ Firebase Auth user created successfully
   UID: xxxxx-xxxxx-xxxxx
   Email: test@example.com
💾 Saving user data to Firestore...
✅ User data saved to Firestore successfully
🎉 === REGISTRATION SUCCESS ===
```

## Logs en Cas d'Erreur Firebase
Cherchez exactement ce format:
```
❌ === FIREBASE AUTH ERROR ===
   Code: [EXACT_ERROR_CODE_HERE]
   Message: [EXACT_MESSAGE_HERE]
   Plugin: firebase_auth
```

## Informations à Fournir
Copiez-collez exactement:
1. Le **Code** exact de l'erreur
2. Le **Message** exact de l'erreur
3. La **ligne de la Console** où l'erreur apparaît
4. Le **numéro de ligne** du fichier d'erreur (s'il y a)

---

## Configuration Firebase Actuelle (pour référence)
- **Projet**: gestion-hotel-app-taham5439
- **Auth Domain**: gestion-hotel-app-taham5439.firebaseapp.com
- **API Key**: AIzaSyDjnmqn6S0EMEm-E9v9A4QU_aZn3DOqZ6U
- **Project ID**: gestion-hotel-app-taham5439

Cette information est vérifiée dans `lib/firebase_options.dart`
