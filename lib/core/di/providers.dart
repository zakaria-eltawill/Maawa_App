import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/config/app_config.dart';
import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/entities/notification.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/domain/repositories/property_repository.dart';
import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/core/network/interceptors/auth_interceptor.dart';
import 'package:maawa_project/core/network/interceptors/idempotency_interceptor.dart';
import 'package:maawa_project/core/network/interceptors/refresh_interceptor.dart';
import 'package:maawa_project/core/router/app_router.dart';
import 'package:maawa_project/core/storage/secure_storage.dart';
import 'package:maawa_project/data/datasources/remote/auth_api.dart';
import 'package:maawa_project/data/datasources/remote/booking_api.dart';
import 'package:maawa_project/data/datasources/remote/notification_api.dart';
import 'package:maawa_project/data/datasources/remote/payment_api.dart';
import 'package:maawa_project/data/datasources/remote/property_api.dart';
import 'package:maawa_project/data/datasources/remote/proposal_api.dart';
import 'package:maawa_project/data/datasources/remote/review_api.dart';
import 'package:maawa_project/data/datasources/remote/image_upload_api.dart';
import 'package:maawa_project/data/repositories/auth_repository_impl.dart';
import 'package:maawa_project/data/repositories/booking_repository_impl.dart';
import 'package:maawa_project/data/repositories/notification_repository_impl.dart';
import 'package:maawa_project/data/repositories/property_repository_impl.dart';
import 'package:maawa_project/data/repositories/proposal_repository_impl.dart';
import 'package:maawa_project/data/repositories/review_repository_impl.dart';
import 'package:maawa_project/domain/usecases/create_booking.dart';
import 'package:maawa_project/domain/usecases/create_proposal.dart';
import 'package:maawa_project/domain/usecases/fetch_properties.dart';
import 'package:maawa_project/domain/usecases/fetch_property_detail.dart';
import 'package:maawa_project/domain/usecases/get_bookings.dart';
import 'package:maawa_project/domain/usecases/get_current_user.dart';
import 'package:maawa_project/domain/usecases/list_owner_proposals.dart';
import 'package:maawa_project/domain/usecases/login.dart';
import 'package:maawa_project/domain/usecases/logout.dart';
import 'package:maawa_project/domain/usecases/owner_decision.dart';
import 'package:maawa_project/domain/usecases/post_review.dart';
import 'package:maawa_project/domain/usecases/register.dart';
import 'package:maawa_project/domain/usecases/register_fcm_token.dart';
import 'package:maawa_project/domain/usecases/update_profile.dart';
import 'package:maawa_project/domain/usecases/change_password.dart';
import 'package:maawa_project/domain/usecases/process_mock_payment.dart';
import 'package:maawa_project/domain/usecases/get_notifications.dart';
import 'package:maawa_project/domain/usecases/mark_notification_read.dart';
import 'package:maawa_project/domain/usecases/mark_all_notifications_read.dart';
import 'package:maawa_project/domain/usecases/get_owner_bookings.dart';
import 'package:maawa_project/domain/usecases/get_owner_properties.dart';
import 'package:maawa_project/domain/usecases/get_booking_by_id.dart';
import 'package:maawa_project/domain/usecases/get_proposal_by_id.dart';
import 'package:maawa_project/domain/usecases/update_proposal.dart';

// Storage
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

// Network
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final baseUrl = AppConfig.baseUrl;

  final authInterceptor = AuthInterceptor(secureStorage);
  final refreshInterceptor = RefreshInterceptor(secureStorage, baseUrl);
  final idempotencyInterceptor = IdempotencyInterceptor();

  final dioClient = DioClient(
    baseUrl: baseUrl,
    interceptors: [
      authInterceptor,
      refreshInterceptor,
      idempotencyInterceptor,
    ],
  );

  return dioClient;
});

// API Clients
final authApiProvider = Provider<AuthApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthApi(dioClient);
});

final propertyApiProvider = Provider<PropertyApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return PropertyApi(dioClient);
});

final bookingApiProvider = Provider<BookingApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return BookingApi(dioClient);
});

final proposalApiProvider = Provider<ProposalApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProposalApi(dioClient);
});

final imageUploadApiProvider = Provider<ImageUploadApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ImageUploadApi(dioClient);
});

final reviewApiProvider = Provider<ReviewApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ReviewApi(dioClient);
});

final paymentApiProvider = Provider<PaymentApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return PaymentApi(dioClient);
});

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return NotificationApi(dioClient);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final authApi = ref.read(authApiProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(authApi, secureStorage);
});

final propertyRepositoryProvider = Provider<PropertyRepositoryImpl>((ref) {
  final propertyApi = ref.read(propertyApiProvider);
  return PropertyRepositoryImpl(propertyApi);
});

final bookingRepositoryProvider = Provider<BookingRepositoryImpl>((ref) {
  final bookingApi = ref.read(bookingApiProvider);
  return BookingRepositoryImpl(bookingApi);
});

final proposalRepositoryProvider = Provider<ProposalRepositoryImpl>((ref) {
  final proposalApi = ref.read(proposalApiProvider);
  return ProposalRepositoryImpl(proposalApi);
});

final reviewRepositoryProvider = Provider<ReviewRepositoryImpl>((ref) {
  final reviewApi = ref.read(reviewApiProvider);
  return ReviewRepositoryImpl(reviewApi);
});

final notificationRepositoryProvider =
    Provider<NotificationRepositoryImpl>((ref) {
  final notificationApi = ref.read(notificationApiProvider);
  return NotificationRepositoryImpl(notificationApi);
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final fetchPropertiesUseCaseProvider = Provider<FetchPropertiesUseCase>((ref) {
  final repository = ref.read(propertyRepositoryProvider);
  return FetchPropertiesUseCase(repository);
});

final fetchPropertyDetailUseCaseProvider =
    Provider<FetchPropertyDetailUseCase>((ref) {
  final repository = ref.read(propertyRepositoryProvider);
  return FetchPropertyDetailUseCase(repository);
});

final createBookingUseCaseProvider = Provider<CreateBookingUseCase>((ref) {
  final repository = ref.read(bookingRepositoryProvider);
  return CreateBookingUseCase(repository);
});

final ownerDecisionUseCaseProvider = Provider<OwnerDecisionUseCase>((ref) {
  final repository = ref.read(bookingRepositoryProvider);
  return OwnerDecisionUseCase(repository);
});

final createProposalUseCaseProvider = Provider<CreateProposalUseCase>((ref) {
  final repository = ref.read(proposalRepositoryProvider);
  return CreateProposalUseCase(repository);
});

final listOwnerProposalsUseCaseProvider =
    Provider<ListOwnerProposalsUseCase>((ref) {
  final repository = ref.read(proposalRepositoryProvider);
  return ListOwnerProposalsUseCase(repository);
});

final getProposalByIdUseCaseProvider = Provider<GetProposalByIdUseCase>((ref) {
  final repository = ref.read(proposalRepositoryProvider);
  return GetProposalByIdUseCase(repository);
});

final updateProposalUseCaseProvider = Provider<UpdateProposalUseCase>((ref) {
  final repository = ref.read(proposalRepositoryProvider);
  return UpdateProposalUseCase(repository);
});

final postReviewUseCaseProvider = Provider<PostReviewUseCase>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return PostReviewUseCase(repository);
});

final registerFcmTokenUseCaseProvider =
    Provider<RegisterFcmTokenUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return RegisterFcmTokenUseCase(repository);
});

final getBookingsUseCaseProvider = Provider<GetBookingsUseCase>((ref) {
  final repository = ref.read(bookingRepositoryProvider);
  return GetBookingsUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return ChangePasswordUseCase(repository);
});

final processMockPaymentUseCaseProvider =
    Provider<ProcessMockPaymentUseCase>((ref) {
  final paymentApi = ref.read(paymentApiProvider);
  return ProcessMockPaymentUseCase(paymentApi);
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return GetNotificationsUseCase(repository);
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkNotificationReadUseCase(repository);
});

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAllNotificationsReadUseCase(repository);
});

final getOwnerBookingsUseCaseProvider = Provider<GetOwnerBookingsUseCase>((ref) {
  final repository = ref.read(bookingRepositoryProvider);
  return GetOwnerBookingsUseCase(repository);
});

// Owner bookings by status providers
final ownerPendingBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.read(bookingRepositoryProvider);
  return await repository.getOwnerBookingsByStatus('pending');
});

final ownerAcceptedBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.read(bookingRepositoryProvider);
  return await repository.getOwnerBookingsByStatus('accepted');
});

final ownerRejectedBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.read(bookingRepositoryProvider);
  return await repository.getOwnerBookingsByStatus('rejected');
});

final getOwnerPropertiesUseCaseProvider = Provider<GetOwnerPropertiesUseCase>((ref) {
  final repository = ref.read(propertyRepositoryProvider);
  return GetOwnerPropertiesUseCase(repository);
});

final getBookingByIdUseCaseProvider = Provider<GetBookingByIdUseCase>((ref) {
  final repository = ref.read(bookingRepositoryProvider);
  return GetBookingByIdUseCase(repository);
});

// Data Providers for Screens
final propertiesProvider = FutureProvider.family<PropertyListResult, PropertyFilters>((ref, filters) async {
  final useCase = ref.read(fetchPropertiesUseCaseProvider);
  return await useCase(filters);
});

final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final useCase = ref.read(getBookingsUseCaseProvider);
  return await useCase();
});

final ownerProposalsProvider = FutureProvider<List<Proposal>>((ref) async {
  final useCase = ref.read(listOwnerProposalsUseCaseProvider);
  return await useCase();
});

final proposalDetailProvider = FutureProvider.family<Proposal, String>((ref, proposalId) async {
  // Use the API to fetch the proposal by ID (backend now supports GET /v1/owner/proposals/{id})
  final useCase = ref.read(getProposalByIdUseCaseProvider);
  return await useCase(proposalId);
});

final currentUserProvider = FutureProvider.autoDispose<User>((ref) async {
  final useCase = ref.read(getCurrentUserUseCaseProvider);
  return await useCase();
});

final notificationsProvider = FutureProvider.family<List<Notification>, bool?>((ref, read) async {
  final useCase = ref.read(getNotificationsUseCaseProvider);
  return await useCase(read: read);
});

final ownerBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final useCase = ref.read(getOwnerBookingsUseCaseProvider);
  return await useCase();
});

final ownerPropertiesProvider = FutureProvider<PropertyListResult>((ref) async {
  final useCase = ref.read(getOwnerPropertiesUseCaseProvider);
  return await useCase();
});

final propertyDetailProvider =
    FutureProvider.family<Property, String>((ref, propertyId) async {
  // Check if current user is an owner
  final currentUserAsync = ref.watch(currentUserProvider);
  
  final property = await currentUserAsync.when(
    data: (user) async {
      final repository = ref.read(propertyRepositoryProvider);
      
      // If user is owner, use owner-specific endpoint
      if (user.role == UserRole.owner) {
        return await repository.getOwnerPropertyById(propertyId);
      } else {
        // For tenants or other roles, use general endpoint
        return await repository.getPropertyById(propertyId);
      }
    },
    loading: () async {
      // While loading user, use general endpoint as fallback
      final repository = ref.read(propertyRepositoryProvider);
      return await repository.getPropertyById(propertyId);
    },
    error: (_, __) async {
      // On error, use general endpoint as fallback
      final repository = ref.read(propertyRepositoryProvider);
      return await repository.getPropertyById(propertyId);
    },
  );
  
  // Backend now includes unavailable_dates in property detail response
  // Use them directly - no need to fetch bookings
  if (kDebugMode) {
    debugPrint('📅 propertyDetailProvider: Property has ${property.unavailableDates.length} unavailable dates from backend');
    if (property.unavailableDates.isNotEmpty) {
      debugPrint('📅   First unavailable date: ${property.unavailableDates.first}');
      debugPrint('📅   Last unavailable date: ${property.unavailableDates.last}');
    } else {
      debugPrint('📅   No unavailable dates - property is fully available');
    }
  }
  
  return property;
});

// Selected booking provider (for passing booking data to detail screen)
// Since backend doesn't have a "Get Booking By ID" endpoint, we store the booking here
// before navigating to the detail screen
final selectedBookingProvider = StateProvider<Booking?>((ref) => null);

final bookingDetailProvider =
    FutureProvider.family<Booking, String>((ref, bookingId) async {
  // Always try API first to get fresh data (especially important after payment/status changes)
  // This ensures we get the latest booking status including is_paid
  try {
    final useCase = ref.read(getBookingByIdUseCaseProvider);
    final freshBooking = await useCase(bookingId);
    if (kDebugMode) {
      debugPrint('✅ BookingDetailProvider: Fetched fresh booking from API: ${freshBooking.id}, status: ${freshBooking.status}, isPaid: ${freshBooking.isPaid}');
    }
    return freshBooking;
  } catch (apiError) {
    if (kDebugMode) {
      debugPrint('⚠️ BookingDetailProvider: API fetch failed, trying cached lists: $apiError');
    }
    
    // If API fails, fall back to cached lists
    Booking? bookingFromList;
    
    try {
      // Try tenant bookings first
      final bookingsFuture = ref.read(bookingsProvider.future);
      final bookings = await bookingsFuture;
      bookingFromList = bookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => throw StateError('Booking not in tenant list'),
      );
      if (kDebugMode) {
        debugPrint('✅ BookingDetailProvider: Found booking in tenant list');
      }
    } catch (e) {
      // Not in tenant list, try owner bookings
      try {
        final ownerBookingsFuture = ref.read(ownerBookingsProvider.future);
        final ownerBookings = await ownerBookingsFuture;
        bookingFromList = ownerBookings.firstWhere(
          (b) => b.id == bookingId,
          orElse: () => throw StateError('Booking not in owner list'),
        );
        if (kDebugMode) {
          debugPrint('✅ BookingDetailProvider: Found booking in owner list');
        }
      } catch (e2) {
        // Not in either list
        bookingFromList = null;
      }
    }
    
    if (bookingFromList != null) {
      return bookingFromList;
    }
    
    // Last resort: try selectedBookingProvider
    final selectedBooking = ref.read(selectedBookingProvider);
    if (selectedBooking != null && selectedBooking.id == bookingId) {
      if (kDebugMode) {
        debugPrint('⚠️ BookingDetailProvider: Using selectedBookingProvider as fallback');
      }
      // Clear the provider after using it (one-time use)
      Future.microtask(() {
        ref.read(selectedBookingProvider.notifier).state = null;
      });
      return selectedBooking;
    }
    
    // Re-throw if no fallback available
    rethrow;
  }
});

// Router
final routerProvider = Provider<AppRouter>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  return AppRouter(secureStorage);
});

