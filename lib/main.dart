import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz/screens/quiz/quiz_play_screen.dart';
import 'firebase_options.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// Admin
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/create_quiz_screen.dart';

// User
import 'screens/user/user_dashboard.dart';
import 'screens/user/join_quiz_screen.dart';
import 'screens/user/quiz_history_screen.dart';

Future<void> main() async {
  debugPrint("🚀 Starting Quiz App");
  print("|||||=== Starting Quiz App ===");
  log("App log started");

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
  } catch (e, stack) {
    debugPrint("❌ Firebase initialization failed: $e");
    debugPrint("$stack");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ Building MyApp widget...");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) {
          debugPrint("➡️ Navigated to AuthScreen");
          return const AuthScreen();
        },
        '/login': (context) {
          debugPrint("➡️ Navigated to LoginScreen");
          return const LoginScreen();
        },
        '/signup': (context) {
          debugPrint("➡️ Navigated to SignupScreen");
          return const SignupScreen();
        },
        '/admin_dashboard': (context) {
          debugPrint("➡️ Navigated to AdminDashboard");
          return const AdminDashboard();
        },
        '/user_dashboard': (context) {
          debugPrint("➡️ Navigated to UserDashboard");
          return const UserDashboard();
        },
        '/join_quiz': (context) {
          debugPrint("➡️ Navigated to JoinQuizScreen");
          return const JoinQuizScreen();
        },
        '/quiz_history': (context) {
          debugPrint("➡️ Navigated to QuizHistoryScreen");
          return const QuizHistoryScreen();
        },
        '/createQuiz': (context) {
          debugPrint("➡️ Navigated to CreateQuizScreen");
          return const CreateQuizScreen();
        },
        '/attemptQuiz': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          if (args == null || !args.containsKey('quizId')) {
            debugPrint("⚠️ AttemptQuiz route called without quizId");
            return const Scaffold(
              body: Center(child: Text('No quiz ID provided')),
            );
          }
          final String quizId = args['quizId'];
          debugPrint("➡️ Navigated to AttemptQuizScreen with quizId: $quizId");
          return QuizPlayScreen(quizId: quizId);
        },
      },
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ Building AuthScreen UI...");
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quiz App',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  debugPrint("➡️ Login button clicked on AuthScreen");
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  debugPrint("➡️ Sign Up button clicked on AuthScreen");
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
