# Maawa Architecture Documentation

This document provides an in-depth look at the architecture and design decisions behind the Maawa property rental platform.

## Table of Contents

- [Overview](#overview)
- [Clean Architecture](#clean-architecture)
- [Project Layers](#project-layers)
- [Data Flow](#data-flow)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Network Layer](#network-layer)
- [Error Handling](#error-handling)
- [Localization](#localization)
- [Testing Strategy](#testing-strategy)

## Overview

Maawa is built using **Clean Architecture** principles, ensuring:
- **Separation of concerns**: Each layer has a specific responsibility
- **Testability**: Business logic is independent and easily testable
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code

## Clean Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (UI, Widgets, Screens, Controllers/Notifiers)         │
│                                                          │
│  Dependencies: Domain Layer                             │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                         │
│  (Entities, Repository Interfaces, Use Cases)           │
│                                                          │
│  Dependencies: None (Pure Dart)                         │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  (DTOs, API Clients, Repository Implementations)        │
│                                                          │
│  Dependencies: Domain Layer                             │
└──────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`lib/presentation/`)
**What it does:**
- Renders UI using Flutter widgets
- Handles user interactions
- Observes state changes using Riverpod
- Calls use cases through providers

**Key Components:**
- **Screens**: Full-page UI components (`PropertyDetailScreen`)
- **Widgets**: Reusable UI components (`AppButton`, `PropertyCard`)
- **Controllers**: State management using Riverpod (`AuthController`)

**Example:**
```dart
class BookingListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    
    return bookingsAsync.when(
      data: (bookings) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

#### 2. **Domain Layer** (`lib/domain/`)
**What it does:**
- Defines business entities (pure Dart objects)
- Declares repository interfaces (contracts)
- Implements business logic in use cases

**Key Components:**
- **Entities**: Business models (`Property`, `Booking`, `User`)
- **Repository Interfaces**: Contracts for data operations
- **Use Cases**: Single-purpose business logic units

**Example Entity:**
```dart
class Property {
  final String id;
  final String name;
  final String city;
  final double pricePerNight;
  final List<String> imageUrls;
  // ... other fields

  const Property({
    required this.id,
    required this.name,
    required this.city,
    required this.pricePerNight,
    required this.imageUrls,
  });
}
```

**Example Use Case:**
```dart
class FetchPropertiesUseCase {
  final PropertyRepository _repository;

  FetchPropertiesUseCase(this._repository);

  Future<PropertyListResult> call(PropertyFilters filters) async {
    return await _repository.getProperties(filters);
  }
}
```

#### 3. **Data Layer** (`lib/data/`)
**What it does:**
- Implements repository interfaces
- Makes API calls using Dio
- Transforms DTOs to domain entities
- Handles data caching and persistence

**Key Components:**
- **DTOs**: JSON serializable models (`PropertyDto`)
- **Data Sources**: API clients (`PropertyApi`)
- **Repository Implementations**: Concrete repository classes

**Example DTO:**
```dart
@JsonSerializable()
class PropertyDto {
  final String id;
  final String name;
  final String city;
  @JsonKey(name: 'price_per_night')
  final double pricePerNight;
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  PropertyDto({...});

  factory PropertyDto.fromJson(Map<String, dynamic> json) =>
      _$PropertyDtoFromJson(json);

  Property toDomain() {
    return Property(
      id: id,
      name: name,
      city: city,
      pricePerNight: pricePerNight,
      imageUrls: imageUrls.map((url) => 
        AppConfig.resolveAssetUrl(url)
      ).toList(),
    );
  }
}
```

## Data Flow

### 1. User Interaction Flow

```
User Tap
    ↓
UI Widget
    ↓
Controller/Provider
    ↓
Use Case
    ↓
Repository Interface
    ↓
Repository Implementation
    ↓
API Client (Dio)
    ↓
Backend API
    ↓
Response
    ↓
DTO → Entity
    ↓
State Update (Riverpod)
    ↓
UI Rebuild
```

### 2. Example: Fetching Properties

```dart
// 1. User opens Discover screen
class PropertyListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the properties provider
    final propertiesAsync = ref.watch(
      propertiesProvider(PropertyFilters())
    );
    
    // 6. Render UI based on state
    return propertiesAsync.when(
      data: (result) => ListView(...),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorState(error),
    );
  }
}

// 3. Provider calls use case
final propertiesProvider = FutureProvider.family<PropertyListResult, PropertyFilters>(
  (ref, filters) async {
    final useCase = ref.read(fetchPropertiesUseCaseProvider);
    return await useCase(filters);
  },
);

// 4. Use case calls repository
class FetchPropertiesUseCase {
  Future<PropertyListResult> call(PropertyFilters filters) async {
    return await _repository.getProperties(filters);
  }
}

// 5. Repository makes API call
class PropertyRepositoryImpl implements PropertyRepository {
  Future<PropertyListResult> getProperties(PropertyFilters filters) async {
    final dtos = await _propertyApi.getProperties(filters);
    final properties = dtos.map((dto) => dto.toDomain()).toList();
    return PropertyListResult(properties: properties);
  }
}
```

## State Management

We use **Riverpod** for state management. It provides:
- Compile-time safety
- Better testability
- Automatic disposal
- Provider composition

### Provider Types

#### 1. **Provider** - For immutable dependencies
```dart
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
```

#### 2. **FutureProvider** - For async data
```dart
final currentUserProvider = FutureProvider<User>((ref) async {
  final useCase = ref.read(getCurrentUserUseCaseProvider);
  return await useCase();
});
```

#### 3. **FutureProvider.family** - For async data with parameters
```dart
final propertyDetailProvider = FutureProvider.family<Property, String>(
  (ref, propertyId) async {
    final useCase = ref.read(fetchPropertyDetailUseCaseProvider);
    return await useCase(propertyId);
  },
);
```

#### 4. **StateNotifierProvider** - For mutable state
```dart
final authControllerProvider = 
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(loginUseCaseProvider),
    ref.read(registerUseCaseProvider),
    ref.read(logoutUseCaseProvider),
  );
});
```

## Navigation

We use **GoRouter** for type-safe, declarative navigation.

### Route Configuration

```dart
final router = GoRouter(
  initialLocation: '/splash',
  redirect: _redirect, // Authentication guard
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeShell(),
      routes: [
        // Nested routes
        GoRoute(
          path: 'property/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PropertyDetailScreen(propertyId: id);
          },
        ),
      ],
    ),
  ],
);
```

### Navigation Examples

```dart
// Push route
context.push('/home/property/123');

// Replace route
context.go('/auth');

// Pop route
context.pop();

// With named parameters
context.push('/home/booking/create/${propertyId}');
```

## Network Layer

### Dio Client Setup

```dart
class DioClient {
  final Dio dio;

  DioClient({
    required String baseUrl,
    required List<Interceptor> interceptors,
  }) : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    dio.interceptors.addAll(interceptors);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }
  
  // ... other methods
}
```

### Interceptors

#### 1. **AuthInterceptor** - Adds JWT token to requests
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
```

#### 2. **RefreshInterceptor** - Handles token refresh
```dart
class RefreshInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt to refresh token
      final newToken = await _refreshToken();
      if (newToken != null) {
        // Retry original request
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      }
    }
    super.onError(err, handler);
  }
}
```

#### 3. **IdempotencyInterceptor** - Prevents duplicate requests
```dart
class IdempotencyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isIdempotentMethod(options.method)) {
      final idempotencyKey = const Uuid().v4();
      options.headers['Idempotency-Key'] = idempotencyKey;
    }
    super.onRequest(options, handler);
  }
}
```

## Error Handling

### Custom Failure Classes

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) 
      : super(message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized']) 
      : super(message);
}
```

### Error Handler

```dart
class ErrorHandler {
  static Failure handleError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('Connection timeout');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return const UnauthorizedFailure();
          }
          return ServerFailure(
            'Server error: ${error.response?.data}',
            statusCode: statusCode,
          );
        
        default:
          return const NetworkFailure();
      }
    }
    return ServerFailure(error.toString());
  }
}
```

## Localization

### ARB Files

We use ARB (Application Resource Bundle) files for localization:

**app_en.arb:**
```json
{
  "@@locale": "en",
  "appTitle": "Maawa",
  "@appTitle": {
    "description": "The application title"
  },
  "welcomeMessage": "Welcome to {appName}",
  "@welcomeMessage": {
    "description": "Welcome message with app name",
    "placeholders": {
      "appName": {
        "type": "String"
      }
    }
  }
}
```

### Usage in Code

```dart
final l10n = AppLocalizations.of(context);

// Simple strings
Text(l10n.appTitle)

// With placeholders
Text(l10n.welcomeMessage('Maawa'))

// Plurals
Text(l10n.numberOfProperties(count))
```

## Testing Strategy

### 1. Unit Tests
Test business logic in isolation (use cases, entities).

```dart
test('FetchPropertiesUseCase returns properties', () async {
  // Arrange
  final mockRepo = MockPropertyRepository();
  when(mockRepo.getProperties(any))
      .thenAnswer((_) async => PropertyListResult(...));
  final useCase = FetchPropertiesUseCase(mockRepo);
  
  // Act
  final result = await useCase(PropertyFilters());
  
  // Assert
  expect(result.properties.length, equals(5));
});
```

### 2. Widget Tests
Test UI components in isolation.

```dart
testWidgets('PropertyCard displays property name', (tester) async {
  // Arrange
  final property = Property(...);
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: PropertyCard(property: property),
    ),
  );
  
  // Assert
  expect(find.text(property.name), findsOneWidget);
});
```

### 3. Integration Tests
Test complete user flows.

```dart
testWidgets('User can complete booking flow', (tester) async {
  // Navigate to property
  await tester.tap(find.text('View Property'));
  await tester.pumpAndSettle();
  
  // Start booking
  await tester.tap(find.text('Book Now'));
  await tester.pumpAndSettle();
  
  // Fill form and submit
  await tester.enterText(find.byKey(Key('check-in')), '2024-01-15');
  await tester.tap(find.text('Confirm Booking'));
  await tester.pumpAndSettle();
  
  // Verify success
  expect(find.text('Booking Confirmed'), findsOneWidget);
});
```

## Performance Optimizations

### 1. Image Caching
```dart
CachedNetworkImage(
  imageUrl: property.imageUrls.first,
  placeholder: (context, url) => ShimmerLoading(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. Lazy Loading
```dart
ListView.builder(
  itemCount: properties.length,
  itemBuilder: (context, index) {
    return PropertyCard(property: properties[index]);
  },
)
```

### 3. Provider Caching
```dart
final propertyDetailProvider = FutureProvider.family.autoDispose<Property, String>(
  (ref, id) async {
    // Cached automatically by Riverpod
    return await useCase(id);
  },
);
```

## Security

### 1. Secure Storage
```dart
// Store sensitive data
await _secureStorage.setAccessToken(token);

// Retrieve securely
final token = await _secureStorage.getAccessToken();
```

### 2. JWT Token Management
- Access tokens for API requests
- Refresh tokens for token renewal
- Automatic token refresh on 401 errors

### 3. Input Validation
- Client-side validation for user inputs
- Server-side validation enforced by backend

---

This architecture ensures a robust, scalable, and maintainable codebase for the Maawa platform.

