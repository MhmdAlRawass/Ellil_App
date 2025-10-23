import 'package:cloud_firestore/cloud_firestore.dart';

class Author {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;

  Author({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
  });

  factory Author.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Author(
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
      'imageUrl': imageUrl,
    };
  }
}
