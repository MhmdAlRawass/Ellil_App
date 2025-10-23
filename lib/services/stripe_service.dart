import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  final _getPrices =
      FirebaseFunctions.instance.httpsCallable('getStripePrices');
  final _createPaymentIntent =
      FirebaseFunctions.instance.httpsCallable('createPaymentIntent');

  final _createBookPaymentIntent =
      FirebaseFunctions.instance.httpsCallable('createBookPaymentIntent');

  Future<List<StripePlan>> getPlans() async {
    final result = await _getPrices();
    final List data = result.data;
    return data
        .map((e) => StripePlan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String priceId, String customerId) async {
    final result = await _createPaymentIntent(
      {
        'priceId': priceId,
        'customerId': customerId,
      },
    );
    return Map<String, dynamic>.from(result.data);
  }

  Future<void> saveSubscriptionToFirestore({
    required String userId,
    required String stripeCustomerId,
    required String stripePriceId,
    required double amount,
    required String currency,
    required String interval,
    required int intervalCount,
    required String planName,
  }) async {
    final startedAt = DateTime.now();
    DateTime endsAt;
    if (interval == 'month') {
      endsAt = startedAt.add(Duration(days: 30 * intervalCount));
    } else if (interval == 'year') {
      endsAt = startedAt.add(Duration(days: 365 * intervalCount));
    } else {
      endsAt = startedAt.add(Duration(days: 30 * intervalCount));
    }

    final subscriptionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc();
    print("Interval: $interval");
    print("Interval Count: $intervalCount");
    print("Started At: $startedAt");
    await subscriptionRef.set({
      'stripeCustomerId': stripeCustomerId,
      'stripePriceId': stripePriceId,
      'amount': amount,
      'currency': currency,
      'interval': interval,
      'intervalCount': intervalCount,
      'status': 'active',
      'startedAt': startedAt,
      'endsAt': endsAt,
      'renewal': true,
      'planName': planName,
    });
  }

  

  Future<bool> purchaseBook({
    required String userId,
    required String bookId,
  }) async {
    try {
      // 1. Call your firebase function
      final result = await _createBookPaymentIntent.call({
        'userId': userId,
        'bookId': bookId,
      });

      final data = Map<String, dynamic>.from(result.data);
      final clientSecret = data['clientSecret'] as String?;
      final customerId = data['customerId'] as String?;

      if (clientSecret == null) throw Exception("Client secret is null");
      // 2️⃣ Initialize Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Ellil',
          customerId: customerId,
        ),
      );

      // 3️⃣ Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4️⃣ Payment succeeded
      return true;
    } catch (err) {
      print("Error creating payment intent: $err");
      return false;
    }
  }
}

class StripePlan {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final String interval;
  final int intervalCount;

  StripePlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.intervalCount,
  });

  factory StripePlan.fromJson(Map<String, dynamic> json) {
    return StripePlan(
      id: json['id'],
      name: json['nickname'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      interval: json['interval'] ?? 'month',
      intervalCount: json['interval_count'] != null
          ? (json['interval_count'] as num).toInt()
          : 1,
    );
  }
}
