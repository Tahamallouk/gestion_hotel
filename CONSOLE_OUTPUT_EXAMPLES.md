# Exemple: Ce que Vous Devriez Voir dans la Console Chrome

## Scénario 1: Inscription RÉUSSIE

Quand vous remplissez le formulaire et cliquez sur "S'inscrire" avec des données valides:

```
🔐 === REGISTRATION START ===
📧 Email: test@example.com
👤 Full Name: John Doe
📱 Phone: +212612345678
📝 Attempting Firebase Auth user creation...
✅ Firebase Auth user created successfully
   UID: U9nX2vZ5qY8wL1mK9nP2
   Email: test@example.com
💾 Saving user data to Firestore...
✅ User data saved to Firestore successfully
🎉 === REGISTRATION SUCCESS ===
```

**Résultat**: 
- ✅ Vous serez redirigé vers l'écran d'accueil
- ✅ Un nouvel utilisateur apparaît dans Firebase Console
- ✅ Un document "test@example.com" dans Firestore collection "users"

---

## Scénario 2: Erreur "operation-not-allowed" (Email/Password non activé)

```
🔐 === REGISTRATION START ===
📧 Email: test@example.com
👤 Full Name: John Doe
📱 Phone: +212612345678
📝 Attempting Firebase Auth user creation...
❌ === FIREBASE AUTH ERROR ===
   Code: operation-not-allowed
   Message: Password sign-in is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Authentication section.
   Plugin: firebase_auth
```

**Cause**: Email/Password n'est pas activé dans Firebase Console

**Solution**:
1. Allez à https://console.firebase.google.com
2. Projet: gestion-hotel-app-taham5439
3. Authentification → Méthode de connexion
4. Activez "Email/Password"
5. Réessayez l'inscription

---

## Scénario 3: Erreur "invalid-api-key" (Clé API invalide)

```
❌ === FIREBASE AUTH ERROR ===
   Code: invalid-api-key
   Message: Invalid API Key provided. Please pass a valid API key.
   Plugin: firebase_auth
```

**Cause**: Clé API Firebase invalide ou avec restrictions

**Solution**:
1. Vérifiez `lib/firebase_options.dart` ligne du web apiKey
2. Allez à Google Cloud Console
3. Vérifiez que les restrictions API n'empêchent pas le web localhost
4. Ou régénérez la clé API sans restrictions

---

## Scénario 4: Erreur "email-already-in-use" (Email déjà enregistré)

```
❌ === FIREBASE AUTH ERROR ===
   Code: email-already-in-use
   Message: The email address is already in use by another account.
   Plugin: firebase_auth
```

**Cause**: Cet email existe déjà dans Firebase

**Solution**: Utilisez une différente adresse email pour tester:
- test1@example.com
- test2@example.com
- votrenomet@example.com
- etc.

---

## Scénario 5: Erreur "weak-password" (Mot de passe faible)

```
❌ === FIREBASE AUTH ERROR ===
   Code: weak-password
   Message: Password should be at least 6 characters.
   Plugin: firebase_auth
```

**Cause**: Mot de passe trop court (< 6 caractères)

**Solution**: Utilisez un mot de passe d'au moins 6 caractères:
- password123
- SecurePass2024
- TestPassword

---

## Scénario 6: Erreur "network-request-failed" (Erreur réseau)

```
❌ === PLATFORM ERROR ===
   Code: network-request-failed
   Message: A network error has occurred.
   Details: null
```

**Cause**: Erreur de connexion réseau ou CORS

**Solution**:
1. Vérifiez votre connexion Internet
2. Dans Firebase Console, allez à Authentification → Paramètres
3. Vérifiez que "localhost" est dans "Domaines autorisés"
4. Sinon, ajoutez-le

---

## Comment Copier un Message d'Erreur Complet

1. **Clic droit** sur le message d'erreur dans la Console
2. Sélectionnez **"Copier le message"** ou **"Copier le contenu"**
3. Ou sélectionnez tout le texte avec **Ctrl+A** et **Ctrl+C**
4. Collez dans le chat pour me montrer l'erreur exacte

---

## Où Chercher si Rien Ne S'Affiche

### Option 1: Console Filtrée
- En haut à droite de la Console, cherchez les **filtres**
- Assurez-vous que **"All"** est sélectionné (pas "Errors" ou "Warnings" uniquement)
- Vérifiez le **niveau** (Info, Warning, Error)

### Option 2: Onglet Network
- Cliquez sur l'onglet **Network**
- Effectuez à nouveau l'inscription
- Cherchez les requêtes vers **"identitytoolkit.googleapis.com"**
- Cliquez dessus et regardez la **Response** pour le message d'erreur JSON

### Option 3: Filtrer par "Erreur"
- En haut à gauche de la Console, cherchez l'icône **🚫 (erreurs)**
- Cliquez dessus pour afficher uniquement les messages d'erreur
- Cherchez les messages contenant **"Firebase"** ou **"Error"**

---

## Boutons et Raccourcis

| Raccourci | Action |
|-----------|--------|
| **F12** | Ouvrir Developer Tools |
| **Ctrl+Shift+I** | Alternative pour ouvrir Developer Tools |
| **Ctrl+Shift+J** | Ouvrir directement la Console |
| **Ctrl+L** | Effacer la Console |
| **Ctrl+F** | Rechercher dans la Console |

---

## Message de Succès vs Message d'Erreur

### Succès = Vert ✅
```
🎉 === REGISTRATION SUCCESS ===
```
- L'utilisateur a été créé dans Firebase Auth
- Les données ont été sauvegardées dans Firestore
- Vous êtes redirigé vers la page d'accueil

### Erreur = Rouge ❌
```
❌ === FIREBASE AUTH ERROR ===
```
- Quelque chose s'est mal passé
- Cherchez le **Code** d'erreur dans le message
- Utilisez la table ci-dessus pour trouver la solution

---

**Prochaine étape**: Effectuez un enregistrement de test et copiez le message exact que vous voyez!
