import 'package:cloud_firestore/cloud_firestore.dart';

class Usern {
  final String id;
  String name;
  String username;
  String bio;
  String? profileImageUrl; // Store URL instead of File

  Usern({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    this.profileImageUrl,
  });

  // Convert Firestore document to User object
  factory Usern.fromMap(Map<String, dynamic> data, String id) {
    return Usern(
      id: id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Convert User object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'lastUpdated': FieldValue.serverTimestamp(), // Auto-managed timestamp
    };
  }

  // Helper for partial updates
  Usern copyWith({
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
  }) {
    return Usern(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
