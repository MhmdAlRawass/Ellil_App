import 'dart:io';

import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/tab_index_notifier.dart';
import 'package:audio_app_example/providers/theme_notifier.dart';
import 'package:audio_app_example/providers/user_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/books_list.dart';
import 'package:audio_app_example/screens/tabs/home.dart';
import 'package:audio_app_example/screens/tabs/library.dart';
import 'package:audio_app_example/screens/tabs/listening.dart';
import 'package:audio_app_example/screens/tabs/profile/profile.dart';
import 'package:audio_app_example/widgets/responsive_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final List<Widget?> _pages = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    setUpNotifications();
  }

  void setUpNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1️⃣ Request permission (iOS + Android 13+)
    if (Platform.isIOS) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('iOS permission: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // Android 13+ needs runtime permission
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }

    // 2️⃣ Get device FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // TODO: Optionally save token to Firestore or your backend for this user
    // FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
    //   'fcmToken': token,
    // });

    // 3️⃣ Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Received foreground message: ${message.notification?.title}');
    });

    // 4️⃣ Handle when user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification opened: ${message.data}');
    });

    // 5️⃣ Handle notification that opened the app from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
          '🚀 App opened from terminated by notification: ${initialMessage.data}');
    }
  }

  bool _shouldShowAppBar(int pageIndex) {
    // Return false for the last page (assuming it's index 4)
    // Adjust this logic based on which pages should hide the app bar
    return pageIndex != 4;

    // Alternative: Hide app bar for multiple pages
    // return pageIndex != 2 && pageIndex != 4; // Hide for pages 2 and 4

    // Alternative: Show app bar only for specific pages
    // return pageIndex == 0 || pageIndex == 1; // Show only for Home and Library
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Home(key: ValueKey("HomePage"));
      case 1:
        return const LibraryScreen(key: ValueKey("LibraryPage"));
      case 2:
        return const ProfileScreen(key: ValueKey("ProfilePage"));
      case 3:
        return const Listening(key: ValueKey("ListeningPage"));
      case 4:
        return const BooksListScreen(key: ValueKey("BookListPage"));
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);
    final colors = Theme.of(context).colorScheme;
    final userAsync = ref.watch(userProvider(currentUser.uid));
    final pageIndex = ref.watch(tabIndexProvider);

    _pages[pageIndex] ??= _buildPage(pageIndex);

    return PopScope(
      canPop: pageIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && pageIndex != 0) {
          ref.read(tabIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        appBar: _shouldShowAppBar(pageIndex)
            ? AppBar(
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 4,
                surfaceTintColor: Colors.transparent,
                backgroundColor: colors.surface,
                iconTheme: IconThemeData(color: colors.onSurface),
                titleTextStyle: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                elevation: 0,
                centerTitle: true,
                title: ResponsiveLogo(
                  maxHeight: kToolbarHeight * 0.85,
                  isDarkMode: isDarkMode,
                ),
              )
            : null,
        body: IndexedStack(
          index: pageIndex,
          children: _pages.map((p) => p ?? const SizedBox()).toList(),
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: pageIndex,
          curve: Curves.linearToEaseOut,
          margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          backgroundColor: colors.surface,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.onSurface,
          onTap: (index) {
            ref.read(tabIndexProvider.notifier).state = index;
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_outlined),
              title: Text(AppLocalizations.tr('home', lang)),
            ),
            SalomonBottomBarItem(
              icon: const ImageIcon(
                AssetImage(
                    'assets/images/icons/ellil_icons_blue/solar_book-bookmark-outline.png'),
              ),
              title: Text(AppLocalizations.tr('library', lang)),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline),
              title: Text(AppLocalizations.tr('profile', lang)),
            ),
            SalomonBottomBarItem(
              icon: const ImageIcon(
                AssetImage(
                    'assets/images/icons/ellil_icons_blue/solar_headphones-round-sound-outline.png'),
              ),
              title: Text(AppLocalizations.tr('listen', lang)),
            ),
            SalomonBottomBarItem(
              icon: const ImageIcon(
                AssetImage(
                    'assets/images/icons/ellil_icons_blue/ellil_icon_blue.png'),
              ),
              title: Text(AppLocalizations.tr('ellil', lang)),
            ),
          ],
        ),
      ),
    );
  }
}
