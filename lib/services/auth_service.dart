import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up new user
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String role, // "admin" or "user"
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  // Login existing user
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await getUserDetails(cred.user!.uid);
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }

  // Fetch user details
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      if (snap.exists) {
        return UserModel.fromMap(snap.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print("Get User Error: $e");
      return null;
    }
  }

  // Listen to auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
