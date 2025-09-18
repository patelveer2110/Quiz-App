class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // "admin" or "user"

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Convert Firestore data to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
