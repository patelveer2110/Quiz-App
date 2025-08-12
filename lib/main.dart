import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz/screens/admin_screen.dart'; // Import your AdminScreen file
import 'package:quiz/screens/auth.dart'; // Import your AuthScreen file
import 'package:quiz/screens/selection_page.dart';
import 'package:quiz/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 199, 188, 226)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            // Check if the logged-in user's email domain is admin.com
            if (FirebaseAuth.instance.currentUser!.email!
                .endsWith('admin.com')) {
              return const AdminScreen();
            } else {
              return const SelectionPage();
            }
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
