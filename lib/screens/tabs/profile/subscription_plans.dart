import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/loading.dart';
import 'package:audio_app_example/models/user_subscription.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/screens/tabs/profile/payment.dart';
import 'package:audio_app_example/services/stripe_service.dart';
import 'package:audio_app_example/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as fs;

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({
    super.key,
    required this.userSubscription,
  });

  final UserSubscription? userSubscription;

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  bool isLoading = true;
  String selectedPlan = '';
  final stripeService = StripeService();
  final userService = UserService();

  List<dynamic> plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final fetchedPlans = await stripeService.getPlans();
      if (mounted) {
        setState(() {
          plans = fetchedPlans;
          if (plans.isNotEmpty) {
            selectedPlan = widget.userSubscription == null
                ? plans.first.id
                : widget.userSubscription!.stripePriceId;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint("Error fetching plans: $e");
    }
  }

  Future<void> onPressedCheckout({
    required StripePlan plan,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Create PaymentIntent & ephemeral key via backend
      final paymentData = await stripeService.createPaymentIntent(
        plan.id,
        user.uid,
      );

      final clientSecret = paymentData['clientSecret'];
      final ephemeralKey = paymentData['ephemeralKey'];
      final stripeCustomerId = paymentData['customerId'];

      // 2️⃣ Initialize Payment Sheet
      await fs.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: fs.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'My App',
          customerId: stripeCustomerId,
          customerEphemeralKeySecret: ephemeralKey,
          style: ThemeMode.system,
        ),
      );

      // 3️⃣ Present Payment Sheet
      await fs.Stripe.instance.presentPaymentSheet();

      // 4️⃣ Save subscription in Firestore with real dates
      final startedAt = DateTime.now();
      DateTime endsAt;

      switch (plan.interval) {
        case 'month':
          endsAt = DateTime(
            startedAt.year,
            startedAt.month + plan.intervalCount,
            startedAt.day,
          );
          break;
        case 'year':
          endsAt = DateTime(
            startedAt.year + plan.intervalCount,
            startedAt.month,
            startedAt.day,
          );
          break;
        default:
          endsAt = startedAt.add(Duration(days: 30 * plan.intervalCount));
      }

      await stripeService.saveSubscriptionToFirestore(
        userId: user.uid,
        stripeCustomerId: stripeCustomerId,
        stripePriceId: plan.id,
        amount: plan.amount,
        currency: plan.currency,
        interval: plan.interval,
        planName: plan.name,
        intervalCount: plan.intervalCount,
      );

      // 5️⃣ Navigate to confirmation page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationPage(
              planName: plan.name,
              amount: plan.amount,
              currency: plan.currency,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final lang = ref.watch(languageProvider);

    if (isLoading) {
      return const Scaffold(body: Loading());
    }

    if (plans.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No plans available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.tr('subscription', lang)),
        actions: widget.userSubscription != null
            ? [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade400),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.tr('sub_active', lang),
                    style: TextStyle(
                      color: Colors.green.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width < 600 ? 16 : 32,
          vertical: size.width < 600 ? 0 : 24,
        ),
        children: [
          Text(
            AppLocalizations.tr('subscription_plans', lang),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          for (var plan in plans)
            _buildSubscriptionOptionCard(
              title: plan.name,
              price:
                  "${plan.amount.toStringAsFixed(2)} ${plan.currency.toUpperCase()}",
              description: "Billed ${plan.interval}",
              isSelected: selectedPlan == plan.id,
              onTap: () => setState(() => selectedPlan = plan.id),
              context: context,
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final selected =
                  plans.firstWhere((plan) => plan.id == selectedPlan);
              onPressedCheckout(
                plan: selected,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.secondary,
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}

Widget _buildSubscriptionOptionCard({
  required String title,
  required String price,
  required String description,
  required bool isSelected,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}
