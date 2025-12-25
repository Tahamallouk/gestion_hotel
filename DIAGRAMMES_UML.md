# 📊 Diagrammes UML - Application Gestion Hôtel

## 🎭 Diagramme de Cas d'Utilisation

```mermaid
graph LR
    Client((Client))
    Admin((Admin))
    
    subgraph "Système Gestion Hôtel"
        UC1[S'authentifier]
        UC2[Consulter Dashboard]
        UC3[Rechercher Hôtels]
        UC4[Voir Détails Hôtel]
        UC5[Réserver Chambre]
        UC6[Consulter Mes Réservations]
        UC7[Annuler Réservation]
        UC8[Modifier Profil]
        
        UC9[Gérer Hôtels]
        UC10[Gérer Chambres]
        UC11[Gérer Toutes Réservations]
        UC12[Voir Statistiques]
        UC13[Dashboard Admin]
    end
    
    %% Relations Client
    Client --> UC1
    Client --> UC2
    Client --> UC3
    Client --> UC4
    Client --> UC5
    Client --> UC6
    Client --> UC7
    Client --> UC8
    
    %% Relations Admin (hérite de Client + fonctions admin)
    Admin --> UC1
    Admin --> UC2
    Admin --> UC9
    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
    
    %% Extensions
    UC3 -.-> UC4
    UC4 -.-> UC5
    UC5 -.-> UC6
```

## 🔄 Diagramme de Séquence - Réservation Chambre

```mermaid
sequenceDiagram
    participant C as Client
    participant UI as Interface
    participant AP as AuthProvider
    participant BP as BookingProvider
    participant FS as FirestoreService
    participant FB as Firebase
    
    Note over C,FB: Processus de Réservation d'une Chambre
    
    C->>UI: Sélectionner chambre
    UI->>AP: Vérifier authentification
    AP-->>UI: Utilisateur connecté
    
    UI->>C: Afficher formulaire réservation
    C->>UI: Sélectionner dates + options
    
    UI->>FS: Vérifier disponibilité
    FS->>FB: Query réservations existantes
    FB-->>FS: Données réservations
    FS-->>UI: Chambre disponible
    
    C->>UI: Confirmer réservation
    UI->>BP: createReservation()
    BP->>FS: Créer nouvelle réservation
    FS->>FB: Sauvegarder en Firestore
    FB-->>FS: Confirmation
    FS-->>BP: Réservation créée
    BP-->>UI: Succès
    UI->>C: Afficher confirmation
```

## 🏗️ Diagramme de Classe Simplifié

```mermaid
classDiagram
    class User {
        +String uid
        +String email
        +String role
        +login()
        +logout()
    }
    
    class Hotel {
        +String id
        +String name
        +String address
        +String city
        +double rating
        +List~Room~ rooms
        +getDetails()
    }
    
    class Room {
        +String id
        +String number
        +String type
        +String view
        +int basePrice
        +int viewExtra
        +bool isAvailable
        +checkAvailability()
    }
    
    class Reservation {
        +String id
        +String userId
        +String hotelId
        +String roomId
        +DateTime startDate
        +DateTime endDate
        +String status
        +int totalPrice
        +cancel()
        +confirm()
    }
    
    class AuthProvider {
        +User currentUser
        +bool isAuthenticated
        +login()
        +logout()
        +notifyListeners()
    }
    
    class BookingProvider {
        +bool isLoading
        +String error
        +createReservation()
        +cancelReservation()
        +notifyListeners()
    }
    
    class FirestoreService {
        +getHotels()
        +getRooms()
        +createReservation()
        +getUserReservations()
        +checkRoomAvailability()
    }
    
    %% Relations
    User ||--o{ Reservation : "fait"
    Hotel ||--o{ Room : "contient"
    Hotel ||--o{ Reservation : "reçoit"
    Room ||--o{ Reservation : "est réservée par"
    
    AuthProvider --> User : "gère"
    BookingProvider --> Reservation : "gère"
    BookingProvider --> FirestoreService : "utilise"
    AuthProvider --> FirestoreService : "utilise"
```

## 📱 Architecture des Composants Flutter

```mermaid
graph TD
    subgraph "Presentation Layer"
        AS[AppShell]
        DP[DashboardPage]
        HP[HotelsPage]
        RP[ReservationsPage]
        PP[ProfilePage]
        AHP[AdminHotelsPage]
    end
    
    subgraph "State Management"
        AuthP[AuthProvider]
        BookP[BookingProvider]
    end
    
    subgraph "Business Logic"
        AuthS[AuthService]
        FS[FirestoreService]
        AdminS[AdminService]
    end
    
    subgraph "Data Layer"
        FB[(Firebase)]
        Models[Models]
    end
    
    AS --> DP
    AS --> HP
    AS --> RP
    AS --> PP
    AS --> AHP
    
    DP --> AuthP
    DP --> BookP
    HP --> AuthP
    RP --> AuthP
    RP --> BookP
    
    AuthP --> AuthS
    BookP --> FS
    
    AuthS --> FB
    FS --> FB
    AdminS --> FB
    
    FS --> Models
    AuthS --> Models
```

## 🎯 Fonctionnalités par Rôle

### 👤 **CLIENT**
- ✅ **Authentification** : Connexion/Déconnexion
- ✅ **Dashboard** : Vue d'ensemble personnalisée
- ✅ **Recherche Hôtels** : Parcourir et filtrer
- ✅ **Détails Hôtel** : Voir chambres et informations
- ✅ **Réservation** : Réserver une chambre avec options
- ✅ **Mes Réservations** : Consulter et gérer ses réservations
- ✅ **Profil** : Modifier ses informations

### 👨‍💼 **ADMIN** 
- ✅ **Dashboard Admin** : Statistiques complètes
- ✅ **Gestion Hôtels** : CRUD complet des hôtels
- ✅ **Gestion Chambres** : CRUD complet des chambres
- ✅ **Gestion Réservations** : Voir/modifier toutes les réservations
- ✅ **Statistiques** : Revenus, occupation, tendances
- ✅ **Filtres Avancés** : Par hôtel, statut, dates

## 🔄 Flux Principal de Réservation

1. **Client se connecte** → AuthProvider vérifie les credentials
2. **Recherche d'hôtel** → HotelsPage affiche la liste
3. **Sélection chambre** → Navigation vers BookRoomScreen
4. **Configuration réservation** → Sélection dates/options
5. **Vérification disponibilité** → FirestoreService vérifie les conflits
6. **Confirmation** → BookingProvider crée la réservation
7. **Sauvegarde** → FirestoreService persiste en Firebase
8. **Notification** → UI affiche le succès

## 📊 Pattern Utilisé: **Provider + Service Layer**

- **Providers** : Gestion d'état réactive (ChangeNotifier)
- **Services** : Logique métier et accès données
- **Features** : Organisation modulaire par fonctionnalité
- **Models** : Structures de données typées

Cette architecture permet une **séparation claire des responsabilités** et une **facilité de maintenance** pour votre projet !