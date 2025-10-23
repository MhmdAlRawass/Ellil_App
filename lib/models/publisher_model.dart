import 'package:cloud_firestore/cloud_firestore.dart';

class Publisher {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final String? type;

  Publisher({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.type,
  });

  factory Publisher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Publisher(
      id: doc.id,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'],
      type: data['type'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
    };
  }
}
