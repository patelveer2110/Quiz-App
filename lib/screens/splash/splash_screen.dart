import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Fetch user role from Firestore
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(user.uid).get();
      String role = snap['role'] ?? 'user';

      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UserDashboard()));
      }
    } else {
      // Not logged in → go to login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
