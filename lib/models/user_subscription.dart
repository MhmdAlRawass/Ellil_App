import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscription {
  final String stripeCustomerId;
  final String stripePriceId;
  final double amount;
  final String currency;
  final String interval;
  final String status;
  final DateTime startedAt;
  final DateTime endsAt;
  final bool renewal;
  final String planName;
  final int intervalCount;

  UserSubscription({
    required this.stripeCustomerId,
    required this.stripePriceId,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.status,
    required this.startedAt,
    required this.endsAt,
    required this.renewal,
    required this.planName,
    required this.intervalCount,
  });

  factory UserSubscription.fromFirestore(Map<String, dynamic> data) {
    return UserSubscription(
      stripeCustomerId: data['stripeCustomerId'],
      stripePriceId: data['stripePriceId'],
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'],
      interval: data['interval'],
      intervalCount: (data['intervalCount'] ?? 1) as int,
      status: data['status'],
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      endsAt: (data['endsAt'] as Timestamp).toDate(),
      renewal: data['renewal'] ?? true,
      planName: data['planName'] ?? 'Standard Plan',
    );
  }
}
