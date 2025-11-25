import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'مأوى'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف'**
  String get discover;

  /// No description provided for @bookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get bookings;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'فلتر'**
  String get filter;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'تم بنجاح'**
  String get success;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @showMore.
  ///
  /// In ar, this message translates to:
  /// **'إظهار المزيد'**
  String get showMore;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In ar, this message translates to:
  /// **'سجل دخولك للوصول إلى حسابك'**
  String get signInToContinue;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createAccount;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @region.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة'**
  String get region;

  /// No description provided for @selectRegion.
  ///
  /// In ar, this message translates to:
  /// **'اختر المنطقة'**
  String get selectRegion;

  /// No description provided for @role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get role;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createNewAccount;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بـ Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithFacebook.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بـ Facebook'**
  String get signInWithFacebook;

  /// No description provided for @orContinueWith.
  ///
  /// In ar, this message translates to:
  /// **'أو تسجيل بإستخدام'**
  String get orContinueWith;

  /// No description provided for @iAgreeToThe.
  ///
  /// In ar, this message translates to:
  /// **'بالمتابعة أنا أوافق على'**
  String get iAgreeToThe;

  /// No description provided for @termsAndConditions.
  ///
  /// In ar, this message translates to:
  /// **'الشروط'**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In ar, this message translates to:
  /// **'و'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الموافقة على الشروط والأحكام'**
  String get pleaseAgreeToTerms;

  /// No description provided for @emailRequired.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مطلوب'**
  String get phoneRequired;

  /// No description provided for @regionRequired.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة مطلوبة'**
  String get regionRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @hello.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get hello;

  /// No description provided for @welcomeMessage.
  ///
  /// In ar, this message translates to:
  /// **'منصة إيجار العقارات في ليبيا'**
  String get welcomeMessage;

  /// No description provided for @searchForProperty.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عقار...'**
  String get searchForProperty;

  /// No description provided for @featuredProperties.
  ///
  /// In ar, this message translates to:
  /// **'العقارات المميزة'**
  String get featuredProperties;

  /// No description provided for @browseByType.
  ///
  /// In ar, this message translates to:
  /// **'تصفح حسب النوع'**
  String get browseByType;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @villa.
  ///
  /// In ar, this message translates to:
  /// **'فيلا'**
  String get villa;

  /// No description provided for @apartment.
  ///
  /// In ar, this message translates to:
  /// **'شقة'**
  String get apartment;

  /// No description provided for @chalet.
  ///
  /// In ar, this message translates to:
  /// **'شاليه'**
  String get chalet;

  /// No description provided for @house.
  ///
  /// In ar, this message translates to:
  /// **'منزل'**
  String get house;

  /// No description provided for @perNight.
  ///
  /// In ar, this message translates to:
  /// **'/ ليلة'**
  String get perNight;

  /// No description provided for @perMonth.
  ///
  /// In ar, this message translates to:
  /// **'/ شهر'**
  String get perMonth;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @neighborhood.
  ///
  /// In ar, this message translates to:
  /// **'مدينة'**
  String get neighborhood;

  /// No description provided for @rented.
  ///
  /// In ar, this message translates to:
  /// **'مؤجر'**
  String get rented;

  /// No description provided for @reserved.
  ///
  /// In ar, this message translates to:
  /// **'محجوز مؤقتاً'**
  String get reserved;

  /// No description provided for @propertyDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العقار'**
  String get propertyDetails;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @amenities.
  ///
  /// In ar, this message translates to:
  /// **'المرافق'**
  String get amenities;

  /// No description provided for @ownerInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المالك'**
  String get ownerInfo;

  /// No description provided for @contactOwner.
  ///
  /// In ar, this message translates to:
  /// **'تواصل'**
  String get contactOwner;

  /// No description provided for @contactTenant.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع المستأجر'**
  String get contactTenant;

  /// No description provided for @viewOnMap.
  ///
  /// In ar, this message translates to:
  /// **'عرض على الخريطة'**
  String get viewOnMap;

  /// No description provided for @bookNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز الآن'**
  String get bookNow;

  /// No description provided for @reserveNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز الآن'**
  String get reserveNow;

  /// No description provided for @bookingDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحجز'**
  String get bookingDetails;

  /// No description provided for @failedToLoadBookingDetails.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل تفاصيل الحجز'**
  String get failedToLoadBookingDetails;

  /// No description provided for @bookingNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على الحجز. قد يكون قد تم حذفه أو أن المعرف غير صحيح.'**
  String get bookingNotFound;

  /// No description provided for @goBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get goBack;

  /// No description provided for @bookingAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الحجز!'**
  String get bookingAccepted;

  /// No description provided for @bookingRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الحجز'**
  String get bookingRejected;

  /// No description provided for @tenantNotified.
  ///
  /// In ar, this message translates to:
  /// **'تم إشعار المستأجر'**
  String get tenantNotified;

  /// No description provided for @tenantWillBeNotified.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إشعار المستأجر بقرارك'**
  String get tenantWillBeNotified;

  /// No description provided for @failedToProcessBooking.
  ///
  /// In ar, this message translates to:
  /// **'فشل معالجة الحجز'**
  String get failedToProcessBooking;

  /// No description provided for @paymentSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح'**
  String get paymentSuccessful;

  /// No description provided for @bookingConfirmedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد حجزك. نتمنى لك إقامة ممتعة!'**
  String get bookingConfirmedMessage;

  /// No description provided for @paymentFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الدفع'**
  String get paymentFailed;

  /// No description provided for @rejectBooking.
  ///
  /// In ar, this message translates to:
  /// **'رفض الحجز'**
  String get rejectBooking;

  /// No description provided for @provideRejectionReason.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تقديم سبب الرفض:'**
  String get provideRejectionReason;

  /// No description provided for @reasonOptional.
  ///
  /// In ar, this message translates to:
  /// **'السبب (اختياري)'**
  String get reasonOptional;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @pricePerNight.
  ///
  /// In ar, this message translates to:
  /// **'السعر لليلة الواحدة'**
  String get pricePerNight;

  /// No description provided for @bookingInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحجز'**
  String get bookingInformation;

  /// No description provided for @checkIn.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الوصول'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ المغادرة'**
  String get checkOut;

  /// No description provided for @nights.
  ///
  /// In ar, this message translates to:
  /// **'ليالي'**
  String get nights;

  /// No description provided for @guests.
  ///
  /// In ar, this message translates to:
  /// **'الضيوف'**
  String get guests;

  /// No description provided for @totalPrice.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get totalPrice;

  /// No description provided for @paymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get paymentStatus;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In ar, this message translates to:
  /// **'غير مدفوع'**
  String get unpaid;

  /// No description provided for @bookingCreated.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ إنشاء الحجز'**
  String get bookingCreated;

  /// No description provided for @tenantInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المستأجر'**
  String get tenantInformation;

  /// No description provided for @emailAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان البريد الإلكتروني'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @bookingTimeline.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحجز'**
  String get bookingTimeline;

  /// No description provided for @rejectionReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get rejectionReason;

  /// No description provided for @acceptBooking.
  ///
  /// In ar, this message translates to:
  /// **'قبول الحجز'**
  String get acceptBooking;

  /// No description provided for @rejectBookingButton.
  ///
  /// In ar, this message translates to:
  /// **'رفض الحجز'**
  String get rejectBookingButton;

  /// No description provided for @bookingAcceptedCompletePayment.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول حجزك! أكمل الدفع لتأكيد إقامتك.'**
  String get bookingAcceptedCompletePayment;

  /// No description provided for @paymentDeadlineWarning.
  ///
  /// In ar, this message translates to:
  /// **'اذا لم يتم الدفع خلال اربع ساعات من وقت قبول طلب حجزك سيتم الغاء الحجز'**
  String get paymentDeadlineWarning;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get payment;

  /// No description provided for @bookingSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الحجز'**
  String get bookingSummary;

  /// No description provided for @arrivalDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الوصول:'**
  String get arrivalDate;

  /// No description provided for @departureDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ المغادرة:'**
  String get departureDate;

  /// No description provided for @numberOfNights.
  ///
  /// In ar, this message translates to:
  /// **'عدد الليالي'**
  String get numberOfNights;

  /// No description provided for @numberOfGuests.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأشخاص'**
  String get numberOfGuests;

  /// No description provided for @people.
  ///
  /// In ar, this message translates to:
  /// **'أشخاص'**
  String get people;

  /// No description provided for @priceDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل السعر'**
  String get priceDetails;

  /// No description provided for @serviceFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الخدمة'**
  String get serviceFee;

  /// No description provided for @valueAddedTax.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get valueAddedTax;

  /// No description provided for @totalAmount.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الكلي'**
  String get totalAmount;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @edfaaly.
  ///
  /// In ar, this message translates to:
  /// **'ادفع لي'**
  String get edfaaly;

  /// No description provided for @mobiCash.
  ///
  /// In ar, this message translates to:
  /// **'موبي كاش'**
  String get mobiCash;

  /// No description provided for @serviceInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الخدمة'**
  String get serviceInformation;

  /// No description provided for @enterPhoneOrServiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف أو رقم الخدمة'**
  String get enterPhoneOrServiceNumber;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار طريقة الدفع'**
  String get selectPaymentMethod;

  /// No description provided for @paymentProcessedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم معالجة الدفع بنجاح. تم تأكيد حجزك الآن.'**
  String get paymentProcessedSuccessfully;

  /// No description provided for @pay.
  ///
  /// In ar, this message translates to:
  /// **'دفع'**
  String get pay;

  /// No description provided for @byClickingPayYouAgree.
  ///
  /// In ar, this message translates to:
  /// **'بالضغط على \"دفع\" فإنك توافق على شروط الخدمة'**
  String get byClickingPayYouAgree;

  /// No description provided for @academicNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة أكاديمية'**
  String get academicNote;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح (من 7 إلى 10 أرقام)'**
  String get invalidPhoneNumber;

  /// No description provided for @payNow.
  ///
  /// In ar, this message translates to:
  /// **'ادفع الآن'**
  String get payNow;

  /// No description provided for @paymentCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع. تم تأكيد حجزك!'**
  String get paymentCompleted;

  /// No description provided for @night.
  ///
  /// In ar, this message translates to:
  /// **'ليلة'**
  String get night;

  /// No description provided for @nightsPlural.
  ///
  /// In ar, this message translates to:
  /// **'ليالٍ'**
  String get nightsPlural;

  /// No description provided for @bookingRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الحجز'**
  String get bookingRequests;

  /// No description provided for @recentBookings.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات الأخيرة'**
  String get recentBookings;

  /// No description provided for @numberOfMonths.
  ///
  /// In ar, this message translates to:
  /// **'مدة الإيجار'**
  String get numberOfMonths;

  /// No description provided for @pricePerMonth.
  ///
  /// In ar, this message translates to:
  /// **'الإيجار الشهري'**
  String get pricePerMonth;

  /// No description provided for @bookingFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الحجز'**
  String get bookingFee;

  /// No description provided for @taxes.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get taxes;

  /// No description provided for @requestBooking.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب الحجز'**
  String get requestBooking;

  /// No description provided for @bookingRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب حجز'**
  String get bookingRequest;

  /// No description provided for @bookingRequested.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الحجز!'**
  String get bookingRequested;

  /// No description provided for @waitingForOwnerApproval.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار موافقة المالك'**
  String get waitingForOwnerApproval;

  /// No description provided for @guestInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المستأجر'**
  String get guestInformation;

  /// No description provided for @additionalNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية (إختياري)'**
  String get additionalNotes;

  /// No description provided for @addNotesPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'أضف أي ملاحظات أو طلبات خاصة...'**
  String get addNotesPlaceholder;

  /// No description provided for @myBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get myBookings;

  /// No description provided for @bookingHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المدفوعات'**
  String get bookingHistory;

  /// No description provided for @activeBookings.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات النشطة'**
  String get activeBookings;

  /// No description provided for @pastBookings.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات السابقة'**
  String get pastBookings;

  /// No description provided for @pendingBookings.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get pendingBookings;

  /// No description provided for @confirmedBookings.
  ///
  /// In ar, this message translates to:
  /// **'مؤكدة'**
  String get confirmedBookings;

  /// No description provided for @completedBookings.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completedBookings;

  /// No description provided for @cancelledBookings.
  ///
  /// In ar, this message translates to:
  /// **'ملغية'**
  String get cancelledBookings;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكدة'**
  String get confirmed;

  /// No description provided for @accepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get rejected;

  /// No description provided for @approved.
  ///
  /// In ar, this message translates to:
  /// **'موافق عليه'**
  String get approved;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get cancelled;

  /// No description provided for @canceled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get canceled;

  /// No description provided for @expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get expired;

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get statusAccepted;

  /// No description provided for @statusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get statusRejected;

  /// No description provided for @statusCanceled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get statusCanceled;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusExpired;

  /// No description provided for @createProposal.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء اقتراح'**
  String get createProposal;

  /// No description provided for @noProposalsFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على اقتراحات'**
  String get noProposalsFound;

  /// No description provided for @createYourFirstProposal.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ اقتراحك الأول لإضافة عقار'**
  String get createYourFirstProposal;

  /// No description provided for @proposalEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاقتراح'**
  String get proposalEdit;

  /// No description provided for @deleteProposal.
  ///
  /// In ar, this message translates to:
  /// **'حذف الاقتراح'**
  String get deleteProposal;

  /// No description provided for @deleteProposalConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الاقتراح؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteProposalConfirmation;

  /// No description provided for @proposalDeletedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الاقتراح بنجاح'**
  String get proposalDeletedSuccessfully;

  /// No description provided for @failedToDeleteProposal.
  ///
  /// In ar, this message translates to:
  /// **'فشل حذف الاقتراح'**
  String get failedToDeleteProposal;

  /// No description provided for @proposalDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الاقتراح'**
  String get proposalDetails;

  /// No description provided for @proposalUpdatedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الاقتراح بنجاح. تم تغيير الحالة إلى قيد الانتظار لمراجعة المسؤول.'**
  String get proposalUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProposal.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحديث الاقتراح'**
  String get failedToUpdateProposal;

  /// No description provided for @approvedProposalCannotBeModified.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة على هذا الاقتراح ولا يمكن تعديله. يمكن تعديل أو حذف الاقتراحات المعلقة أو المرفوضة فقط.'**
  String get approvedProposalCannotBeModified;

  /// No description provided for @onlyPendingOrRejectedCanBeModified.
  ///
  /// In ar, this message translates to:
  /// **'يمكن تعديل الاقتراحات المعلقة أو المرفوضة فقط.'**
  String get onlyPendingOrRejectedCanBeModified;

  /// No description provided for @youDontHavePermissionToModify.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك إذن لتعديل هذا الاقتراح.'**
  String get youDontHavePermissionToModify;

  /// No description provided for @title.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get title;

  /// No description provided for @titleRequired.
  ///
  /// In ar, this message translates to:
  /// **'العنوان مطلوب'**
  String get titleRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In ar, this message translates to:
  /// **'الوصف مطلوب'**
  String get descriptionRequired;

  /// No description provided for @cityRequired.
  ///
  /// In ar, this message translates to:
  /// **'المدينة مطلوبة'**
  String get cityRequired;

  /// No description provided for @propertyTypeRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار نوع العقار'**
  String get propertyTypeRequired;

  /// No description provided for @priceRequired.
  ///
  /// In ar, this message translates to:
  /// **'السعر مطلوب'**
  String get priceRequired;

  /// No description provided for @priceInvalid.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم صحيح'**
  String get priceInvalid;

  /// No description provided for @locationUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط الموقع'**
  String get locationUrl;

  /// No description provided for @locationUrlInvalid.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رابط صحيح'**
  String get locationUrlInvalid;

  /// No description provided for @locationUrlRequired.
  ///
  /// In ar, this message translates to:
  /// **'رابط الموقع مطلوب'**
  String get locationUrlRequired;

  /// No description provided for @locationRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد الموقع باستخدام GPS أو رابط Google Maps'**
  String get locationRequired;

  /// No description provided for @invalidCoordinates.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رابط Google Maps صحيح يحتوي على الإحداثيات'**
  String get invalidCoordinates;

  /// No description provided for @getCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'الحصول على موقعي الحالي'**
  String get getCurrentLocation;

  /// No description provided for @gettingLocation.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحصول على الموقع...'**
  String get gettingLocation;

  /// No description provided for @locationRetrieved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحصول على الموقع'**
  String get locationRetrieved;

  /// No description provided for @locationRetrievedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم الحصول على الموقع بنجاح'**
  String get locationRetrievedSuccessfully;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الموقع معطلة. يرجى تفعيلها من الإعدادات'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع. يرجى السماح بالوصول إلى الموقع'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @failedToGetLocation.
  ///
  /// In ar, this message translates to:
  /// **'فشل الحصول على الموقع'**
  String get failedToGetLocation;

  /// No description provided for @latitude.
  ///
  /// In ar, this message translates to:
  /// **'خط العرض'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In ar, this message translates to:
  /// **'خط الطول'**
  String get longitude;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @photos.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get photos;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @uploading.
  ///
  /// In ar, this message translates to:
  /// **'جاري الرفع'**
  String get uploading;

  /// No description provided for @failedToUploadPhotos.
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الصور'**
  String get failedToUploadPhotos;

  /// No description provided for @submitProposal.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الاقتراح'**
  String get submitProposal;

  /// No description provided for @proposalSubmittedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الاقتراح بنجاح'**
  String get proposalSubmittedSuccessfully;

  /// No description provided for @failedToSubmitProposal.
  ///
  /// In ar, this message translates to:
  /// **'فشل إرسال الاقتراح'**
  String get failedToSubmitProposal;

  /// No description provided for @failedToPickImage.
  ///
  /// In ar, this message translates to:
  /// **'فشل اختيار الصورة'**
  String get failedToPickImage;

  /// No description provided for @failedToTakePhoto.
  ///
  /// In ar, this message translates to:
  /// **'فشل التقاط الصورة'**
  String get failedToTakePhoto;

  /// No description provided for @challete.
  ///
  /// In ar, this message translates to:
  /// **'شاليه'**
  String get challete;

  /// No description provided for @browseProperties.
  ///
  /// In ar, this message translates to:
  /// **'تصفح العقارات'**
  String get browseProperties;

  /// No description provided for @payRent.
  ///
  /// In ar, this message translates to:
  /// **'دفع الإيجار'**
  String get payRent;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @cancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get cancelBooking;

  /// No description provided for @bookingConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الحجز'**
  String get bookingConfirmed;

  /// No description provided for @paidAmount.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get paidAmount;

  /// No description provided for @dueAmount.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get dueAmount;

  /// No description provided for @startDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get endDate;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الإيجار'**
  String get duration;

  /// No description provided for @months.
  ///
  /// In ar, this message translates to:
  /// **'أشهر'**
  String get months;

  /// No description provided for @paymentDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل السعر'**
  String get paymentDetails;

  /// No description provided for @paymentInformation.
  ///
  /// In ar, this message translates to:
  /// **'بيانات البطاقة'**
  String get paymentInformation;

  /// No description provided for @cardNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In ar, this message translates to:
  /// **'رمز الأمان'**
  String get cvv;

  /// No description provided for @cardHolderName.
  ///
  /// In ar, this message translates to:
  /// **'اسم حامل البطاقة'**
  String get cardHolderName;

  /// No description provided for @cardHolderNamePlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'الاسم كما هو مكتوب على البطاقة'**
  String get cardHolderNamePlaceholder;

  /// No description provided for @creditDebitCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة الائتمان / خصم'**
  String get creditDebitCard;

  /// No description provided for @bankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get bankTransfer;

  /// No description provided for @eWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة إلكترونية'**
  String get eWallet;

  /// No description provided for @securePayment.
  ///
  /// In ar, this message translates to:
  /// **'دفع آمن ومحمي'**
  String get securePayment;

  /// No description provided for @securePaymentDesc.
  ///
  /// In ar, this message translates to:
  /// **'جميع المعاملات محمية بتشفير SSL وتقنيات الأمان المتقدمة. لن يتم حفظ بيانات البطاقة على خوادمنا.'**
  String get securePaymentDesc;

  /// No description provided for @academicNoteDesc.
  ///
  /// In ar, this message translates to:
  /// **'هذا دفع يرمز للأغراض الأكاديمية. لن يتم خصم أي مبلغ فعلي من بطاقتك.'**
  String get academicNoteDesc;

  /// No description provided for @processPayment.
  ///
  /// In ar, this message translates to:
  /// **'دفع {amount} دل'**
  String processPayment(String amount);

  /// No description provided for @proceedToPayment.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة إلى الدفع'**
  String get proceedToPayment;

  /// No description provided for @agreeToPaymentTerms.
  ///
  /// In ar, this message translates to:
  /// **'بالنقر على \"دفع\" موافق توافق على شروط الخدمة.'**
  String get agreeToPaymentTerms;

  /// No description provided for @myProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @accountInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحساب'**
  String get accountInformation;

  /// No description provided for @personalInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInformation;

  /// No description provided for @userInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المستخدم'**
  String get userInformation;

  /// No description provided for @tenant.
  ///
  /// In ar, this message translates to:
  /// **'مستأجر'**
  String get tenant;

  /// No description provided for @owner.
  ///
  /// In ar, this message translates to:
  /// **'مالك'**
  String get owner;

  /// No description provided for @admin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get admin;

  /// No description provided for @rating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// No description provided for @properties.
  ///
  /// In ar, this message translates to:
  /// **'العقارات'**
  String get properties;

  /// No description provided for @myProperties.
  ///
  /// In ar, this message translates to:
  /// **'عقاراتي'**
  String get myProperties;

  /// No description provided for @editProperty.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العقار'**
  String get editProperty;

  /// No description provided for @proposals.
  ///
  /// In ar, this message translates to:
  /// **'الاقتراحات'**
  String get proposals;

  /// No description provided for @joinedSince.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ'**
  String get joinedSince;

  /// No description provided for @currentRental.
  ///
  /// In ar, this message translates to:
  /// **'الإيجار الحالي'**
  String get currentRental;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupport;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والخصوصية'**
  String get privacy;

  /// No description provided for @legalInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات قانونية'**
  String get legalInfo;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهوية'**
  String get nationalId;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @reviewsAndRatings.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviewsAndRatings;

  /// No description provided for @writeReview.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تقييم'**
  String get writeReview;

  /// No description provided for @leaveReview.
  ///
  /// In ar, this message translates to:
  /// **'اترك تقييم'**
  String get leaveReview;

  /// No description provided for @yourRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك'**
  String get yourRating;

  /// No description provided for @yourReview.
  ///
  /// In ar, this message translates to:
  /// **'رأيك'**
  String get yourReview;

  /// No description provided for @submitReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get submitReview;

  /// No description provided for @noReviews.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noReviews;

  /// No description provided for @noRatingAndReviews.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تقييم ومراجعات بعد'**
  String get noRatingAndReviews;

  /// No description provided for @rateYourExperience.
  ///
  /// In ar, this message translates to:
  /// **'قيم تجربتك'**
  String get rateYourExperience;

  /// No description provided for @comment.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get comment;

  /// No description provided for @shareYourExperience.
  ///
  /// In ar, this message translates to:
  /// **'شارك تجربتك...'**
  String get shareYourExperience;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @reviewSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال التقييم!'**
  String get reviewSubmitted;

  /// No description provided for @thankYouForReview.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لمشاركة تجربتك'**
  String get thankYouForReview;

  /// No description provided for @failedToSubmitReview.
  ///
  /// In ar, this message translates to:
  /// **'فشل إرسال التقييم'**
  String get failedToSubmitReview;

  /// No description provided for @reviewOnlyAfterStay.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تقييم العقارات فقط بعد إكمال الإقامة'**
  String get reviewOnlyAfterStay;

  /// No description provided for @propertyNotFound.
  ///
  /// In ar, this message translates to:
  /// **'العقار غير موجود'**
  String get propertyNotFound;

  /// No description provided for @invalidReviewData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التقييم غير صحيحة. يرجى التحقق من المدخلات.'**
  String get invalidReviewData;

  /// No description provided for @dateUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'هذا التاريخ غير متاح'**
  String get dateUnavailable;

  /// No description provided for @dateUnavailableMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا التاريخ محجوز بالفعل. يرجى اختيار تاريخ آخر.'**
  String get dateUnavailableMessage;

  /// No description provided for @ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ'**
  String get ago;

  /// No description provided for @week.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get week;

  /// No description provided for @weeks.
  ///
  /// In ar, this message translates to:
  /// **'أسابيع'**
  String get weeks;

  /// No description provided for @month.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get month;

  /// No description provided for @filters.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get filters;

  /// No description provided for @priceRange.
  ///
  /// In ar, this message translates to:
  /// **'نطاق السعر'**
  String get priceRange;

  /// No description provided for @propertyType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العقار'**
  String get propertyType;

  /// No description provided for @bedrooms.
  ///
  /// In ar, this message translates to:
  /// **'غرف النوم'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In ar, this message translates to:
  /// **'دورات المياه'**
  String get bathrooms;

  /// No description provided for @sortBy.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get sortBy;

  /// No description provided for @applyFilters.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الفلاتر'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get clearFilters;

  /// No description provided for @minPrice.
  ///
  /// In ar, this message translates to:
  /// **'أدنى سعر'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In ar, this message translates to:
  /// **'أقصى سعر'**
  String get maxPrice;

  /// No description provided for @somethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get somethingWentWrong;

  /// No description provided for @noInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get serverError;

  /// No description provided for @notFound.
  ///
  /// In ar, this message translates to:
  /// **'غير موجود'**
  String get notFound;

  /// No description provided for @unauthorized.
  ///
  /// In ar, this message translates to:
  /// **'غير مصرح'**
  String get unauthorized;

  /// No description provided for @connectionTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال'**
  String get connectionTimeout;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @failedToLoad.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحميل'**
  String get failedToLoad;

  /// No description provided for @noDataAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noDataAvailable;

  /// No description provided for @emptyState.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر'**
  String get emptyState;

  /// No description provided for @noPropertiesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على عقارات'**
  String get noPropertiesFound;

  /// No description provided for @noBookingsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات بعد'**
  String get noBookingsYet;

  /// No description provided for @adminAccessNotSupported.
  ///
  /// In ar, this message translates to:
  /// **'الوصول للمدراء غير مدعوم على الموبايل. يرجى استخدام واجهة الويب.'**
  String get adminAccessNotSupported;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @benghazi.
  ///
  /// In ar, this message translates to:
  /// **'بنغازي'**
  String get benghazi;

  /// No description provided for @libya.
  ///
  /// In ar, this message translates to:
  /// **'ليبيا'**
  String get libya;

  /// No description provided for @wifi.
  ///
  /// In ar, this message translates to:
  /// **'واي فاي'**
  String get wifi;

  /// No description provided for @parking.
  ///
  /// In ar, this message translates to:
  /// **'موقف سيارات'**
  String get parking;

  /// No description provided for @balcony.
  ///
  /// In ar, this message translates to:
  /// **'شرفة'**
  String get balcony;

  /// No description provided for @pool.
  ///
  /// In ar, this message translates to:
  /// **'مسبح'**
  String get pool;

  /// No description provided for @gym.
  ///
  /// In ar, this message translates to:
  /// **'صالة رياضة'**
  String get gym;

  /// No description provided for @airConditioning.
  ///
  /// In ar, this message translates to:
  /// **'تكييف'**
  String get airConditioning;

  /// No description provided for @furnished.
  ///
  /// In ar, this message translates to:
  /// **'مفروش'**
  String get furnished;

  /// No description provided for @kitchen.
  ///
  /// In ar, this message translates to:
  /// **'مطبخ'**
  String get kitchen;

  /// No description provided for @laundry.
  ///
  /// In ar, this message translates to:
  /// **'غسيل'**
  String get laundry;

  /// No description provided for @security.
  ///
  /// In ar, this message translates to:
  /// **'حراسة'**
  String get security;

  /// No description provided for @elevator.
  ///
  /// In ar, this message translates to:
  /// **'مصعد'**
  String get elevator;

  /// No description provided for @garden.
  ///
  /// In ar, this message translates to:
  /// **'حديقة'**
  String get garden;

  /// No description provided for @tv.
  ///
  /// In ar, this message translates to:
  /// **'تلفزيون'**
  String get tv;

  /// No description provided for @heating.
  ///
  /// In ar, this message translates to:
  /// **'تدفئة'**
  String get heating;

  /// No description provided for @petFriendly.
  ///
  /// In ar, this message translates to:
  /// **'تسمح بالحيوانات'**
  String get petFriendly;

  /// No description provided for @smokingAllowed.
  ///
  /// In ar, this message translates to:
  /// **'يسمح بالتدخين'**
  String get smokingAllowed;

  /// No description provided for @aboutMaawa.
  ///
  /// In ar, this message translates to:
  /// **'حول مأوى'**
  String get aboutMaawa;

  /// No description provided for @propertyRentalPlatform.
  ///
  /// In ar, this message translates to:
  /// **'منصة تأجير العقارات'**
  String get propertyRentalPlatform;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get frequentlyAskedQuestions;

  /// No description provided for @howDoIBookProperty.
  ///
  /// In ar, this message translates to:
  /// **'كيف أحجز عقاراً؟'**
  String get howDoIBookProperty;

  /// No description provided for @howDoIBookPropertyAnswer.
  ///
  /// In ar, this message translates to:
  /// **'تصفح العقارات في تبويب الرئيسية، اختر عقاراً، حدد تواريخك، واضغط \"احجز الآن\". سيراجع المالك طلبك.'**
  String get howDoIBookPropertyAnswer;

  /// No description provided for @howDoIPayBooking.
  ///
  /// In ar, this message translates to:
  /// **'كيف أدفع مقابل حجزي؟'**
  String get howDoIPayBooking;

  /// No description provided for @howDoIPayBookingAnswer.
  ///
  /// In ar, this message translates to:
  /// **'بعد أن يقبل المالك حجزك، ستصلك إشعار. اذهب إلى تبويب حجوزاتي واضغط \"ادفع الآن\" لإتمام الدفع.'**
  String get howDoIPayBookingAnswer;

  /// No description provided for @canICancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'هل يمكنني إلغاء حجزي؟'**
  String get canICancelBooking;

  /// No description provided for @canICancelBookingAnswer.
  ///
  /// In ar, this message translates to:
  /// **'نعم، يمكنك إلغاء الحجوزات من تبويب حجوزاتي. يرجى ملاحظة أن سياسات الإلغاء قد تنطبق حسب شروط مالك العقار.'**
  String get canICancelBookingAnswer;

  /// No description provided for @howDoISubmitProposal.
  ///
  /// In ar, this message translates to:
  /// **'كيف أقدم اقتراح عقار؟'**
  String get howDoISubmitProposal;

  /// No description provided for @howDoISubmitProposalAnswer.
  ///
  /// In ar, this message translates to:
  /// **'كمالك عقار، اذهب إلى تبويب الاقتراحات واضغط \"اقتراح جديد\". املأ تفاصيل العقار وأرسل للمراجعة.'**
  String get howDoISubmitProposalAnswer;

  /// No description provided for @howDoIContactOwner.
  ///
  /// In ar, this message translates to:
  /// **'كيف أتواصل مع مالك عقار؟'**
  String get howDoIContactOwner;

  /// No description provided for @howDoIContactOwnerAnswer.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك التواصل مع مالكي العقارات من خلال صفحة تفاصيل العقار. تظهر معلومات الاتصال الخاصة بهم هناك.'**
  String get howDoIContactOwnerAnswer;

  /// No description provided for @needMoreHelp.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج مساعدة إضافية؟'**
  String get needMoreHelp;

  /// No description provided for @contactSupportMessage.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان لديك أي أسئلة أو تحتاج مساعدة، يرجى الاتصال بفريق الدعم لدينا.'**
  String get contactSupportMessage;

  /// No description provided for @contactSupport.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بالدعم'**
  String get contactSupport;

  /// No description provided for @dataSecurity.
  ///
  /// In ar, this message translates to:
  /// **'أمان البيانات'**
  String get dataSecurity;

  /// No description provided for @yourDataIsProtected.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك محمية'**
  String get yourDataIsProtected;

  /// No description provided for @encryptedCommunication.
  ///
  /// In ar, this message translates to:
  /// **'اتصال مشفر'**
  String get encryptedCommunication;

  /// No description provided for @encryptedCommunicationDesc.
  ///
  /// In ar, this message translates to:
  /// **'جميع البيانات المنقولة بين جهازك وخوادمنا مشفرة باستخدام بروتوكولات SSL/TLS.'**
  String get encryptedCommunicationDesc;

  /// No description provided for @secureAuthentication.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة الآمنة'**
  String get secureAuthentication;

  /// No description provided for @secureAuthenticationDesc.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم رموز JWT للمصادقة الآمنة. كلمة المرور الخاصة بك لا تُخزن أبداً كنص عادي.'**
  String get secureAuthenticationDesc;

  /// No description provided for @secureStorage.
  ///
  /// In ar, this message translates to:
  /// **'التخزين الآمن'**
  String get secureStorage;

  /// No description provided for @secureStorageDesc.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الحساسة مثل الرموز والاعتمادات تُخزن بشكل آمن على جهازك باستخدام تخزين مشفر.'**
  String get secureStorageDesc;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In ar, this message translates to:
  /// **'خصوصيتك مهمة'**
  String get yourPrivacyMatters;

  /// No description provided for @weRespectYourPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'نحترم خصوصيتك'**
  String get weRespectYourPrivacy;

  /// No description provided for @dataCollection.
  ///
  /// In ar, this message translates to:
  /// **'جمع البيانات'**
  String get dataCollection;

  /// No description provided for @dataCollectionDesc.
  ///
  /// In ar, this message translates to:
  /// **'نجمع فقط المعلومات الضرورية لتقديم خدماتنا: الاسم، البريد الإلكتروني، رقم الهاتف، والبيانات المتعلقة بالعقارات.'**
  String get dataCollectionDesc;

  /// No description provided for @dataSharing.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة البيانات'**
  String get dataSharing;

  /// No description provided for @dataSharingDesc.
  ///
  /// In ar, this message translates to:
  /// **'لا نبيع أو نشارك معلوماتك الشخصية مع أطراف ثالثة دون موافقتك الصريحة.'**
  String get dataSharingDesc;

  /// No description provided for @dataDeletion.
  ///
  /// In ar, this message translates to:
  /// **'حذف البيانات'**
  String get dataDeletion;

  /// No description provided for @dataDeletionDesc.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك طلب حذف حسابك والبيانات المرتبطة به في أي وقت عن طريق الاتصال بالدعم.'**
  String get dataDeletionDesc;

  /// No description provided for @libyanDataProtection.
  ///
  /// In ar, this message translates to:
  /// **'حماية البيانات الليبية'**
  String get libyanDataProtection;

  /// No description provided for @libyanDataProtectionDesc.
  ///
  /// In ar, this message translates to:
  /// **'نلتزم بلوائح حماية البيانات المعمول بها في ليبيا. يتم معالجة وتخزين بياناتك وفقاً للقوانين المحلية.'**
  String get libyanDataProtectionDesc;

  /// No description provided for @termsAndConditionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsAndConditionsTitle;

  /// No description provided for @termsAndConditionsIntro.
  ///
  /// In ar, this message translates to:
  /// **'باستخدام مأوى، أنت توافق على شروط الخدمة الخاصة بنا. النقاط الرئيسية:'**
  String get termsAndConditionsIntro;

  /// No description provided for @term18Years.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون المستخدمون 18 عاماً أو أكثر لاستخدام المنصة'**
  String get term18Years;

  /// No description provided for @termOwnerResponsibility.
  ///
  /// In ar, this message translates to:
  /// **'مالكو العقارات مسؤولون عن دقة قوائم العقارات'**
  String get termOwnerResponsibility;

  /// No description provided for @termTenantResponsibility.
  ///
  /// In ar, this message translates to:
  /// **'المستأجرون مسؤولون عن الدفع ورعاية العقار'**
  String get termTenantResponsibility;

  /// No description provided for @termCancellationPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسات الإلغاء يحددها مالكو العقارات'**
  String get termCancellationPolicy;

  /// No description provided for @questionsAboutPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة حول الخصوصية؟'**
  String get questionsAboutPrivacy;

  /// No description provided for @privacyQuestionsMessage.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان لديك أسئلة حول ممارسات الخصوصية أو التعامل مع البيانات، يرجى الاتصال بنا.'**
  String get privacyQuestionsMessage;

  /// No description provided for @contactPrivacyTeam.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بفريق الخصوصية'**
  String get contactPrivacyTeam;

  /// No description provided for @onboardingWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في مأوى'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'منصة إيجار العقارات في ليبيا'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عقارك المثالي'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In ar, this message translates to:
  /// **'تصفح مجموعة واسعة من العقارات المتاحة للإيجار في جميع أنحاء ليبيا. ابحث حسب الموقع، النوع، والسعر.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In ar, this message translates to:
  /// **'احجز بسهولة'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In ar, this message translates to:
  /// **'احجز العقار الذي تريده بخطوات بسيطة. حدد تواريخ الإقامة وعدد الضيوف وأكمل الحجز بسهولة.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In ar, this message translates to:
  /// **'إدارة حجوزاتك'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In ar, this message translates to:
  /// **'تابع جميع حجوزاتك من مكان واحد. احصل على تحديثات فورية حول حالة حجزك وادفع بسهولة.'**
  String get onboardingPage3Description;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get onboardingSkip;

  /// No description provided for @propertyStatistics.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات العقار'**
  String get propertyStatistics;

  /// No description provided for @bookingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات'**
  String get bookingsLabel;

  /// No description provided for @totalRevenue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get totalRevenue;

  /// No description provided for @ratingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get ratingsLabel;

  /// No description provided for @averageRating.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم'**
  String get averageRating;

  /// No description provided for @type.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get type;

  /// No description provided for @submissionInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الإرسال'**
  String get submissionInformation;

  /// No description provided for @submitted.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال'**
  String get submitted;

  /// No description provided for @lastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get lastUpdated;

  /// No description provided for @adminNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الإدارة'**
  String get adminNotes;

  /// No description provided for @failedToLoadProposal.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الاقتراح'**
  String get failedToLoadProposal;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get sendCode;

  /// No description provided for @enterCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز'**
  String get enterCode;

  /// No description provided for @invalidCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز يجب أن يكون 4 أو 6 أرقام'**
  String get invalidCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
