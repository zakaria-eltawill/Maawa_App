import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/app.dart';
import 'package:maawa_project/core/helpers/notifications_helper.dart';
import 'package:maawa_project/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Handling a background message ${message.messageId}');
    debugPrint('notif +: ${message.data}');
    debugPrint('message--');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('⚠️ Please run "flutterfire configure" to set up Firebase properly.');
    debugPrint('⚠️ Or update firebase_options.dart with your Firebase project credentials.');
    // App will continue but Firebase features won't work
  }

  // iOS: Get APNS token
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.getAPNSToken().then((apnToken) async {
      if (kDebugMode) {
        debugPrint('apnToken: $apnToken');
      }
    });
  }

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set up Flutter local notifications
  await setupFlutterNotifications();

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('message-');
    }
    showFlutterNotification(message);
  });

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
