import 'package:cloud_firestore/cloud_firestore.dart';

class Narrator {
  final String id;
  final String name;
  final String bio;
  final String? imageUrl;

  Narrator({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
  });

  factory Narrator.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Narrator(
      id: doc.id,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'bio': bio,
    };
  }
}
