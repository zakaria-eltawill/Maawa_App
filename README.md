# Maawa - Property Rental Platform 🏠

[![Flutter](https://img.shields.io/badge/Flutter-3.5.4-blue.svg)](https://flutter.dev/)
[![Laravel](https://img.shields.io/badge/Laravel-11.x-red.svg)](https://laravel.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern property rental platform built with Flutter and Laravel, designed for the Libyan market. Maawa connects property owners with tenants through a seamless booking experience.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Frontend Setup](#frontend-setup)
  - [Backend Setup](#backend-setup)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### For Tenants
- 🔍 **Property Discovery**: Browse and search properties with advanced filters
- 📅 **Easy Booking**: Request bookings with date selection and guest count
- 💳 **Mock Payment**: Secure mock payment system for confirmed bookings
- ⭐ **Reviews**: Rate and review properties after your stay
- 📱 **Push Notifications**: Real-time updates via Firebase Cloud Messaging
- 🌍 **Localization**: Full support for Arabic and English

### For Property Owners
- 🏡 **Property Management**: Add, edit, and delete property listings
- 📋 **Booking Management**: Accept or reject booking requests
- 📊 **Dashboard**: Track bookings and property performance
- 📝 **Proposals**: Submit property proposals with detailed information
- 🔔 **Notifications**: Instant alerts for new bookings and reviews

### Platform Features
- 🔐 **Authentication**: Secure JWT-based authentication with refresh tokens
- 🎨 **Modern UI**: Material 3 design with smooth animations
- 🌙 **RTL Support**: Full right-to-left language support for Arabic
- 📱 **Responsive**: Optimized for all screen sizes
- 🚀 **Performance**: Shimmer loading, cached images, and optimized API calls
- 🔄 **Error Handling**: Comprehensive error states with retry actions

## 🛠 Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.5.4
- **State Management**: Riverpod 2.x
- **Navigation**: GoRouter
- **Networking**: Dio with interceptors
- **Local Storage**: Flutter Secure Storage
- **Image Caching**: Cached Network Image
- **Localization**: flutter_localizations & intl
- **Firebase**: Cloud Messaging (FCM)

### Backend (Laravel)
- **Framework**: Laravel 11.x
- **Database**: MySQL/PostgreSQL
- **Authentication**: JWT (tymon/jwt-auth)
- **API**: RESTful API with pagination
- **File Storage**: Local/S3 for images
- **Notifications**: Firebase Admin SDK

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.5.4 or higher
- **Dart SDK**: 3.5.0 or higher
- **PHP**: 8.2 or higher
- **Composer**: Latest version
- **MySQL**: 8.0 or higher (or PostgreSQL)
- **Node.js**: For Laravel Mix (optional)

### Frontend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/maawa_project.git
   cd maawa_project
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional, for push notifications)
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective directories
   - Or run: `flutterfire configure` (recommended)

4. **Generate code** (for JSON serialization)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Configure API endpoint**
   - Open `lib/core/config/app_config.dart`
   - Update `API_BASE_URL` with your backend URL:
     ```dart
     static const String API_BASE_URL = 'http://your-backend-url/v1';
     ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install Composer dependencies**
   ```bash
   composer install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Update `.env` file** with your database credentials:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=maawa_db
   DB_USERNAME=your_username
   DB_PASSWORD=your_password

   JWT_SECRET=your_jwt_secret
   ```

5. **Run migrations**
   ```bash
   php artisan migrate
   ```

6. **Seed database** (optional)
   ```bash
   php artisan db:seed
   ```

7. **Start the server**
   ```bash
   php artisan serve
   ```
   The backend will be available at `http://localhost:8000`

## 🏗 Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                  # Core utilities and configurations
│   ├── config/           # App configuration
│   ├── di/               # Dependency injection (Riverpod providers)
│   ├── error/            # Error handling
│   ├── network/          # Network layer (Dio, interceptors)
│   ├── router/           # Navigation (GoRouter)
│   ├── storage/          # Local storage (Secure Storage)
│   └── theme/            # App theme and styling
├── data/                  # Data layer
│   ├── datasources/      # Remote API clients
│   ├── dto/              # Data Transfer Objects
│   └── repositories/     # Repository implementations
├── domain/                # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic use cases
├── presentation/          # Presentation layer
│   ├── auth/             # Authentication screens
│   ├── booking/          # Booking screens
│   ├── discover/         # Property discovery
│   ├── home/             # Home shell with bottom nav
│   ├── owner/            # Owner-specific features
│   ├── profile/          # User profile
│   ├── review/           # Reviews
│   └── widgets/          # Reusable UI components
└── l10n/                  # Localization files
```

### Key Architecture Patterns

1. **Clean Architecture**: Clear separation between data, domain, and presentation layers
2. **Repository Pattern**: Abstract data sources behind repository interfaces
3. **Use Cases**: Single-responsibility business logic units
4. **Provider Pattern**: Riverpod for dependency injection and state management
5. **DTO Pattern**: Separate DTOs from domain entities for flexibility

## 📁 Project Structure

### Frontend Key Files

- `lib/main.dart` - App entry point
- `lib/core/router/app_router.dart` - Navigation configuration
- `lib/core/di/providers.dart` - Dependency injection setup
- `lib/core/config/app_config.dart` - App configuration
- `lib/core/theme/app_theme.dart` - Theme configuration
- `pubspec.yaml` - Dependencies and assets

### Backend Key Files (Laravel)

- `routes/api.php` - API routes definition
- `app/Http/Controllers/` - API controllers
- `app/Models/` - Eloquent models
- `database/migrations/` - Database migrations
- `config/jwt.php` - JWT configuration

## 📡 API Documentation

### Base URL
```
http://your-backend-url/v1
```

### Authentication Endpoints

#### POST `/auth/register`
Register a new user.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "tenant",
  "phone_number": "0912345678",
  "region": "Benghazi"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbG...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbG...",
  "expires_in": 3600,
  "user": {
    "id": "1",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "tenant",
    "phone_number": "0912345678",
    "region": "Benghazi"
  }
}
```

#### POST `/auth/login`
Login with email and password.

#### POST `/auth/logout`
Logout (requires authentication).

#### POST `/auth/refresh`
Refresh access token using refresh token.

#### GET `/me`
Get current user information (requires authentication).

#### PUT `/me`
Update user profile (requires authentication).

### Property Endpoints

#### GET `/properties`
List all properties with pagination and filters.

**Query Parameters:**
- `page` - Page number
- `per_page` - Items per page
- `city` - Filter by city
- `type` - Filter by property type
- `min_price` - Minimum price
- `max_price` - Maximum price

#### GET `/properties/{id}`
Get property details by ID.

### Booking Endpoints

#### GET `/bookings`
Get user's bookings (requires authentication).

#### POST `/bookings`
Create a new booking (requires authentication).

**Request Body:**
```json
{
  "property_id": "1",
  "check_in": "2024-01-15T00:00:00Z",
  "check_out": "2024-01-20T00:00:00Z",
  "guests": 2
}
```

#### GET `/bookings/{id}`
Get booking details by ID.

#### POST `/owner/bookings/{id}/decision`
Owner accepts or rejects a booking (requires owner role).

**Request Body:**
```json
{
  "decision": "ACCEPT",
  "reason": "Optional rejection reason"
}
```

### Payment Endpoints

#### POST `/payments/mock`
Process a mock payment for testing (requires authentication).

**Request Body:**
```json
{
  "booking_id": "1",
  "fail": false
}
```

### Proposal Endpoints

#### GET `/owner/proposals`
Get owner's property proposals (requires owner role).

#### POST `/proposals`
Create a new property proposal (requires owner role).

#### GET `/proposals/{id}`
Get proposal details by ID.

### Review Endpoints

#### POST `/properties/{id}/reviews`
Post a review for a property (requires authentication).

**Request Body:**
```json
{
  "rating": 5,
  "comment": "Great property!"
}
```

### Notification Endpoints

#### POST `/me/fcm-tokens`
Register FCM token for push notifications (requires authentication).

**Request Body:**
```json
{
  "token": "fcm_token_here",
  "platform": "android"
}
```

#### DELETE `/me/fcm-tokens/{token}`
Unregister FCM token (requires authentication).

## 📸 Screenshots

_Add screenshots of your app here_

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Laravel team for the robust backend framework
- All contributors who helped make this project better

## 📞 Support

For support, email support@maawa.com or join our Slack channel.

---

Made with ❤️ in Libya
