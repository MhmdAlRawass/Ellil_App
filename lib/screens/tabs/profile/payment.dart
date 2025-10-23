import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:audio_app_example/services/stripe_service.dart';
import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/models/loading.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String priceId;
  final String planName;
  final double amount;
  final String currency;
  final String interval;

  const PaymentScreen({
    super.key,
    required this.priceId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.interval,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final stripeService = StripeService();
  bool isLoading = false;

  Future<void> _startPayment() async {
    setState(() => isLoading = true);

    try {
      // 1️⃣ Call backend to create PaymentIntent & ephemeral key
      final paymentData = await stripeService.createPaymentIntent(
        widget.priceId,
        "test_customer_id",
      );

      // 2️⃣ Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentData['clientSecret'],
          merchantDisplayName: 'Test App',
          customerId: paymentData['customerId'],
          customerEphemeralKeySecret: paymentData['ephemeralKey'],
          // optional
          style: ThemeMode.light,
        ),
      );

      // 3️⃣ Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4️⃣ On success, navigate to confirmation
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationPage(
              planName: widget.planName,
              amount: widget.amount,
              currency: widget.currency,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.tr('payment', lang)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Loading()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.planName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.amount.toStringAsFixed(2)} ${widget.currency.toUpperCase()} / ${widget.interval}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startPayment,
                    child: const Text("Subscribe"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Test mode: use 4242 4242 4242 4242 as card number",
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

class PaymentConfirmationPage extends StatelessWidget {
  final String planName;
  final double amount;
  final String currency;

  const PaymentConfirmationPage({
    super.key,
    required this.planName,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Success")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              Text(
                "You have successfully subscribed to $planName!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                "Amount: ${amount.toStringAsFixed(2)} ${currency.toUpperCase()}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("Go to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
