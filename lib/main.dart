import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maawa_project/core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - app will work without it)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will continue without Firebase. Run "flutterfire configure" to set up Firebase.');
  }
  
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
