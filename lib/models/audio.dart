// class for the audios from the firestore
class AppAudio {
  final String uid;

  AppAudio(this.uid);
}

// Extended audio data class with paywall support
class AppAudioData {
  final String name;
  final String uid;
  final String author;
  final String description;
  final double price;           // New: price to access/play this audio
  final bool purchased;         // New: has the user purchased this audio

  AppAudioData({
    required this.name,
    required this.uid,
    required this.author,
    required this.description,
    this.price = 0.0,           // Default: free unless specified
    this.purchased = false,     // Default: not purchased
  });

  // Deserialize from Firestore/JSON
  factory AppAudioData.fromMap(Map<String, dynamic> map) {
    return AppAudioData(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] != null ? (map['price'] as num).toDouble() : 0.0,
      purchased: map['purchased'] ?? false,
    );
  }

  // Serialize to Firestore/JSON
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'author': author,
      'description': description,
      'price': price,
      'purchased': purchased,
    };
  }

  // Optionally: Helper for UI lock/unlock
  bool get isLocked => !purchased && price > 0;
}
