# Maawa Flutter App

Tenant/Owner mobile app built with Flutter using Clean Architecture.

## Features

- **Authentication**: Login, Register, JWT token management with automatic refresh
- **Property Discovery**: Browse properties with filters (city, type, price, date)
- **Booking Management**: Create bookings, view timeline, owner decision flow
- **Proposals (Owner)**: Submit property proposals (ADD/EDIT/DELETE)
- **Reviews**: Post reviews after completed stays
- **Push Notifications**: FCM integration for booking and proposal events
- **Localization**: English and Arabic (RTL support)
- **Material 3 Design**: Clean, modern UI matching admin panel

## Architecture

Clean Architecture with:
- **Domain Layer**: Entities, repositories (interfaces), use cases
- **Data Layer**: DTOs, API clients, repository implementations
- **Presentation Layer**: Screens, controllers (Riverpod), widgets

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code (DTOs):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Configure Firebase:
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Configure API base URL:
   - Dev: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1`
   - Prod: `flutter run --dart-define=API_BASE_URL=https://api.maawa.example/v1`

## Running the App

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1

# Production
flutter run --dart-define=API_BASE_URL=https://api.maawa.example/v1 --release
```

## Project Structure

```
lib/
├── core/           # Infrastructure (router, theme, network, storage)
├── domain/         # Business logic (entities, repositories, use cases)
├── data/           # Data layer (DTOs, API clients, repository implementations)
└── presentation/   # UI (screens, controllers, widgets)
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/unit/auth_interceptor_test.dart
```

## Building

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Notes

- Admin role is not supported on mobile (shows error and signs out)
- JWT tokens are stored securely using `flutter_secure_storage`
- Automatic token refresh on 401 errors
- Idempotency keys are automatically added to mutating requests
- RTL support for Arabic locale
- Offline caching for property lists (read-only)

