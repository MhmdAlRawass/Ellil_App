import 'package:audio_app_example/providers/theme_notifier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Services-old/switcher.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'providers/language_notifier.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

// Use your NEW Firebase config for web:
const FirebaseOptions firebaseWebOptions = FirebaseOptions(
  apiKey: 'AIzaSyDjZu8khLz5savFCkOaZotAq0iRoMacdJM',
  appId: '1:136000759075:web:59ffd9e07d73bd9f2b5896',
  messagingSenderId: '136000759075',
  projectId: 'ellil-37740',
  authDomain: 'ellil-37740.firebaseapp.com',
  databaseURL: 'https://ellil-37740-default-rtdb.firebaseio.com',
  storageBucket: 'ellil-37740.appspot.com',
  measurementId: 'G-FHGK3594JM',
);

// Global variables (your app state, unchanged)
MaterialColor pcolor = Colors.orange;
Color bcolor = const Color(0xFFD3EEE9);
Color tcolor = Colors.black;
Color grad = const Color.fromARGB(255, 220, 163, 88);
bool theme = false;
String logo = 'assets/images/LOGO2.png';
String audioUrl = '';
String image = '';
String audioTitle = '';
String audioDescription = '';
String research = '';
String playlist = '';
bool tester = false;
int likeNbr = 0;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: kIsWeb ? firebaseWebOptions : null,
  );
  // You can handle the background message here
  // print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Stripe **after Flutter binding and Firebase**
  Stripe.publishableKey = 'pk_test_51RqVng8HUEflQFzNAQgdHQHRbe18yaXlic8z2JrOg0VXCEdNO6o13MrIWWtZxJ6lcJ4dzznN9V4Ekka7wtjX4Nyz00bTmaLl7A';
  // Optional: set merchant identifier for Apple Pay / Google Pay
  await Stripe.instance.applySettings();

  runApp(const ProviderScope(child: MyApp()));
}

// Define your brand colors here// Brand Colors
const Color iceColor = Color(0xFFD3EEE9);
const Color goldColor = Color(0xFFC8A959);
const Color blueColor = Color(0xFF33485D);
const Color dustColor = Color(0xFFEAD6CD);
const Color greenColor = Color(0xFF3D7268);
const Color copperColor = Color(0xFF6DB195);

// Light Mode Color Scheme
const ColorScheme lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: goldColor,
  onPrimary: iceColor,
  secondary: greenColor,
  onSecondary: iceColor,
  error: Colors.red,
  onError: Colors.white,
  surface: Color(0xFFD3EEE9),
  onSurface: blueColor,
);

// Dark Mode Color Scheme
const ColorScheme darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: copperColor,
  onPrimary: blueColor,
  secondary: dustColor,
  onSecondary: blueColor,
  tertiary: goldColor,
  error: Colors.red,
  onError: Colors.black,
  surface: blueColor,
  onSurface: iceColor,
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            locale: lang == AppLanguage.arabic
                ? const Locale('ar')
                : const Locale('en'),
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              // Add Flutter's built-in localization delegates
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: 'Flutter OnePage Design',
            theme: ThemeData(
              colorScheme: lightScheme,
              scaffoldBackgroundColor: lightScheme.surface,
            ),
            darkTheme: ThemeData(
              colorScheme: darkScheme,
              scaffoldBackgroundColor: darkScheme.surface,
            ),
            themeMode: themeMode,
            home: const Switcher(),
          );
        });
  }
}
