import 'package:audio_app_example/models/loading.dart';
import 'package:audio_app_example/providers/sleep_timer_notifier.dart';
import 'package:audio_app_example/providers/user_notifier.dart';
import 'package:audio_app_example/screens/tabs/profile/sleep_timer.dart';
import 'package:audio_app_example/services/authentification.dart';
import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/user_subscription.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/theme_notifier.dart';
import 'package:audio_app_example/screens/auth/login.dart';
import 'package:audio_app_example/screens/tabs/profile/subscription_plans.dart';
import 'package:audio_app_example/services/sleeptimer_service.dart';
import 'package:audio_app_example/services/user_service.dart';
import 'package:audio_app_example/widgets/profile/settings_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isLoading = false;
  final AuthenticationService _auth = AuthenticationService();
  final userAuth = FirebaseAuth.instance.currentUser;

  // user info
  UserSubscription? userSubscription;
  bool isSubscribed = false;
  final userService = UserService();

  @override
  void initState() {
    super.initState();
    // _loadUserSubscription();
  }

  onPressedSignOut() {
    _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) {
          return const LoginPage();
        },
      ),
    );
  }

  onPressedNavigateToPlans() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return SubscriptionPlansScreen(
            userSubscription: userSubscription,
          );
        },
      ),
    );
  }

  Future<void> _loadUserSubscription() async {
    if (mounted) setState(() => isLoading = true);

    if (userAuth == null) return;

    final sub = await userService.getUserSubscription(userAuth!.uid);
    if (mounted) {
      setState(() {
        userSubscription = sub;
        isLoading = false;
        if (DateTime.now().isAfter(sub?.endsAt ?? DateTime.now())) {
          isSubscribed = false;
        } else {
          isSubscribed = sub != null;
        }
      });
    }
  }

  showTimerDialog(BuildContext context) {
    // final sleepTimer = SleepTimerService(audioPlayer: audioPlayer, saveProgress: saveProgress)
    showDialog(
        context: context,
        builder: (_) {
          return const SleepTimerScreen();
        });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final userAsync = ref.watch(userProvider(userAuth!.uid));
    final subscriptionAsync =
        ref.watch(userSubscriptionProvider(userAuth!.uid));
    final timerRemaining = ref.watch(sleepTimerProvider);
    final isTimerRunning = timerRemaining != null;

    if (userAsync.isLoading || subscriptionAsync.isLoading) {
      return const Loading();
    }

    if (userAsync.hasError || subscriptionAsync.hasError) {
      return const Center(
        child: Text(
          'An Error occured fetching user. Please try again later',
        ),
      );
    }

    final user = userAsync.value;
    final userSubscriptionValue = subscriptionAsync.value;
    final isSubscribedNow = userSubscriptionValue != null &&
        DateTime.now().isBefore(userSubscriptionValue.endsAt);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 600 ? 16 : 32,
        vertical: size.width < 600 ? 0 : 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 18,
            ),
            Text(
              AppLocalizations.tr('profile', lang),
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            _buildProfileCard(
              context,
              name: user?.name ?? '',
              email: user?.email ?? '',
            ),
            _buildPlaceholder(
              title: AppLocalizations.tr('subscription', lang),
              context: context,
            ),
            _buildSubscriptionCard(
              context,
              isSubscribed: isSubscribedNow,
              planName: userSubscriptionValue?.planName ?? "Basic",
              expiryDate: isSubscribedNow
                  ? DateFormat('d/M/y').format(userSubscriptionValue.endsAt)
                  : 'N/A',
              onPressed: onPressedNavigateToPlans,
              lang: lang,
            ),
            _buildPlaceholder(
              title: AppLocalizations.tr('playback_settings', lang),
              context: context,
            ),
            // SettingsTile(
            //   icon: Icons.audiotrack_rounded,
            //   onPressed: () {},
            //   isSwitcher: true,
            //   title: AppLocalizations.tr('autoplay_title', lang),
            //   subTitle: AppLocalizations.tr('autoplay_subtitle', lang),
            //   switchValue: true,
            // ),
            SettingsTile(
              icon: Icons.timer_outlined,
              onPressed: () {
                showTimerDialog(context);
              },
              title: AppLocalizations.tr('timer_title', lang),
              subTitle: AppLocalizations.tr('timer_subtitle', lang),
            ),
            _buildPlaceholder(
              title: AppLocalizations.tr('app_settings', lang),
              context: context,
            ),
            SettingsTile(
              icon: Icons.language_outlined,
              title: AppLocalizations.tr('language_title', lang),
              subTitle: AppLocalizations.tr('language_subtitle', lang),
              isSwitcher: true,
              onSwitchChanged: (val) {
                ref
                    .read(languageProvider.notifier)
                    .setLanguage(val ? AppLanguage.arabic : AppLanguage.latin);
              },
              switchValue: lang == AppLanguage.arabic,
            ),
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: AppLocalizations.tr('dark_mode_title', lang),
              subTitle: AppLocalizations.tr('dark_mode_subtitle', lang),
              isSwitcher: true,
              switchValue: Theme.of(context).brightness == Brightness.dark,
              onSwitchChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme(value);
              },
            ),
            // SettingsTile(
            //   icon: Icons.file_download_outlined,
            //   title: AppLocalizations.tr('download_title', lang),
            //   subTitle: AppLocalizations.tr('download_subtitle', lang),
            //   isSwitcher: true,
            //   onPressed: () {},
            //   switchValue: true,
            // ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: AppLocalizations.tr('notifications_title', lang),
              subTitle: AppLocalizations.tr('notifications_subtitle', lang),
            ),
            Align(
              alignment: Alignment.center,
              child: _buildSignOutBtn(
                context,
                text: AppLocalizations.tr('sign_out', lang),
                onTap: onPressedSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileCard(
  BuildContext context, {
  required String name,
  required String email,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        width: 1,
        color: Colors.grey,
      ),
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 35,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _buildPlaceholder(
    {required String title, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsetsGeometry.only(bottom: 12, top: 20),
    child: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildSignOutBtn(BuildContext context,
    {required String text, required Function() onTap}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.red, width: 1),
        ),
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.logout,
            color: Colors.red,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSubscriptionCard(BuildContext context,
    {required bool isSubscribed,
    String? planName,
    String? expiryDate,
    required VoidCallback onPressed,
    required AppLanguage lang}) {
  return isSubscribed
      ? GestureDetector(
          onTap: onPressed,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1),
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified,
                              color: Colors.green, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.tr('subscribed', lang),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("${AppLocalizations.tr('plan', lang)}: $planName",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                          "${AppLocalizations.tr('valid_until', lang)}: $expiryDate",
                          style: Theme.of(context).textTheme.bodyMedium),
                      // const SizedBox(height: 12),
                      // ElevatedButton.icon(
                      //   onPressed: onPressed,
                      //   icon: const Icon(Icons.card_membership_outlined),
                      //   label: const Text("Manage Subscription"),
                      // )
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onPressed,
                    icon: const Icon(Icons.edit_outlined),
                  )
                ],
              )),
        )
      : SettingsTile(
          icon: Icons.card_membership_outlined,
          title: AppLocalizations.tr('no_active_subscription', lang),
          subTitle: AppLocalizations.tr('subscribe_now', lang),
          onPressed: onPressed,
        );
}
