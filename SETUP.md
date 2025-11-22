# Maawa Flutter App - Setup Guide

## Prerequisites

1. Flutter SDK (3.24+)
2. Dart 3.x
3. Android Studio / Xcode (for mobile development)
4. Firebase project configured

## Initial Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code (DTOs)

The project uses `json_serializable` for DTOs. Generate the code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `.g.dart` files for all DTOs in `lib/data/dto/`.

### 3. Firebase Configuration

#### Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Ensure `android/build.gradle` includes the Google Services plugin

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`
3. Add it to Xcode project

### 4. Configure API Base URL

The app uses `--dart-define` to set the API base URL:

**Development:**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1
```

**Production:**
```bash
flutter run --dart-define=API_BASE_URL=https://api.maawa.example/v1 --release
```

For Android emulator, use `10.0.2.2` to access localhost.
For iOS simulator, use `localhost` or your machine's IP.

## Running the App

### Development Mode
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1
```

### Release Mode
```bash
flutter run --dart-define=API_BASE_URL=https://api.maawa.example/v1 --release
```

## Project Structure

```
lib/
├── core/                    # Infrastructure
│   ├── app.dart            # Root app widget
│   ├── config/             # App configuration
│   ├── di/                 # Dependency injection (Riverpod)
│   ├── error/              # Error handling
│   ├── l10n/               # Localization files
│   ├── network/            # Dio client and interceptors
│   ├── router/             # go_router configuration
│   ├── storage/            # Secure storage
│   └── theme/              # Material 3 theme
├── domain/                 # Business logic
│   ├── entities/           # Domain models
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases
├── data/                   # Data layer
│   ├── datasources/        # API clients and local cache
│   ├── dto/                # Data transfer objects
│   └── repositories/       # Repository implementations
└── presentation/           # UI layer
    ├── auth/               # Authentication screens
    ├── booking/            # Booking screens
    ├── discover/           # Property discovery
    ├── home/               # Home shell
    ├── notifications/      # Push notification handler
    ├── owner/              # Owner-specific screens
    ├── profile/            # Profile and settings
    ├── review/             # Review screens
    └── widgets/            # Reusable widgets
```

## Key Features Implemented

### Authentication
- ✅ Login/Register screens
- ✅ JWT token storage (secure storage)
- ✅ Automatic token refresh on 401
- ✅ Admin role detection (shows error and signs out)

### Network
- ✅ Dio client with interceptors
- ✅ Auth interceptor (attaches JWT)
- ✅ Refresh interceptor (handles token refresh)
- ✅ Idempotency interceptor (adds UUID to mutating requests)
- ✅ Error handling (Problem+JSON parsing)

### Localization
- ✅ English and Arabic support
- ✅ RTL support for Arabic
- ✅ Localization files (en.arb, ar.arb)

### UI Components
- ✅ Material 3 theme (matching admin panel)
- ✅ Reusable widgets (AppButton, AppTextField, AppCard, etc.)
- ✅ Clean, modern design

## Next Steps (TODO)

### Implementation
1. **Complete Screen Implementations**
   - Add Riverpod providers for property list, bookings, proposals
   - Implement data loading and state management
   - Add error handling and loading states

2. **FCM Integration**
   - Complete push notification handler
   - Register FCM tokens on login
   - Handle notification taps (deep linking)

3. **Property Discovery**
   - Implement filters (city, type, price, date)
   - Add property list with pagination
   - Implement property detail screen with image gallery

4. **Booking Flow**
   - Complete booking creation
   - Implement booking timeline
   - Add owner decision flow
   - Implement mock payment

5. **Proposals (Owner)**
   - Complete proposal forms (ADD/EDIT/DELETE)
   - Add location picker/map integration
   - Implement proposal status tracking

6. **Reviews**
   - Complete review creation
   - Display reviews on property detail

7. **Profile & Settings**
   - Display user profile
   - Add language toggle (EN/AR)
   - Implement logout

### Testing
1. Unit tests for interceptors, mappers, use cases
2. Widget tests for screens
3. Integration tests for auth flow

### Additional Features
1. Offline caching (read-only property lists)
2. Image caching (cached_network_image)
3. Google Maps integration for property locations
4. Date range validation for bookings

## Troubleshooting

### Code Generation Issues
If you see errors about missing `.g.dart` files:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Issues
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in the correct locations
- Check Firebase project configuration
- Verify package names match Firebase project

### Network Issues
- Check API base URL is correct
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Verify backend is running and accessible

### Build Issues
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart versions
- Ensure all dependencies are compatible

## Notes

- Admin role is not supported on mobile (shows error and signs out)
- JWT tokens are stored securely using `flutter_secure_storage`
- Automatic token refresh on 401 errors
- Idempotency keys are automatically added to mutating requests
- RTL support for Arabic locale
- Material 3 design matching admin panel

