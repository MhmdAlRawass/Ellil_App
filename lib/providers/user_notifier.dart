import 'package:audio_app_example/models/user_model.dart';
import 'package:audio_app_example/models/user_subscription.dart';
import 'package:audio_app_example/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StreamProvider.family<User, String>((ref, userId) {
  final service = UserService();

  return service.getUserStreamById(userId);
});

final userSubscriptionProvider =
    StreamProvider.family<UserSubscription?, String>((ref, userId) {
  final service = UserService();

  // This should return a stream that emits updates whenever the user's subscription changes
  return service.getUserSubscriptionStream(userId);
});
