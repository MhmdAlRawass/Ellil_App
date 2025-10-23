import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Successful')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/check-mark.json',
              width: 150,
              height: 150,
              repeat: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank you for your subscription!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
