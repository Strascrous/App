# Strascrous
Strascrous est une application Flutter permettant de consulter les menus des restaurants universitaires et cafétérias du CROUS dans ta ville 

Cette application est pour le moment uniquement disponible pour **Android**.

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install)
- Le SDK Android
- Un appareil Android (un émulateur ou un appareil physique) 
- Une instance de l’API Strascrous accessible depuis l’appareil

## Installation et lancement

Depuis la racine du dépôt :
```sh
flutter pub get
```

### Configurer l’API

L’URL de l’API est définie dans [`lib/api/config.dart`](lib/api/config.dart) :
```dart
const String PROD_BASE_URL = 'http://localhost:3000';
```
Vous devez adapter l'URL à votre environnement.

Le code source de l'API est disponible dans le dépôt [Strascrous/API](https://github.com/Strascrous/API).

### Démarrer l’application
```sh
flutter devices
flutter run
```

## Développement
### Organisation du projet

```text
lib/
├── main.dart                 # Initialisation, thèmes et routage
├── api/                      # Utilisation de l'API
├── components/               # Composants réutilisables
├── providers/                # Gestion du thème
├── routes/                   # Les différents écrans de l'application
└── utils/                    # Utilitaires
assets/
├── icons/                    # Icônes
└── app_icon                  # Icônes de l'application
android/                      # Application Android
```

### Générer un APK
```sh
flutter build apk --release
```

L’APK est généré dans `build/app/outputs/flutter-apk/app-release.apk`.

## Licence
Ce projet est sous [licence MIT](LICENSE).
