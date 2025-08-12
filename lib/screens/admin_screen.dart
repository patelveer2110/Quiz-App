import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz/screens/auth.dart';
import 'package:quiz/screens/manage_questions.dart';
import 'package:quiz/screens/view_result_page.dart';

class AdminScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const AdminScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    // Define a custom color theme
    final ThemeData theme = ThemeData(
      primaryColor: Colors.indigo, // Primary color for app bar and buttons
      hintColor: Colors.indigoAccent, // Accent color for additional elements
      scaffoldBackgroundColor: Colors.white, // Background color for scaffold
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white, // Text color of the app bar title
            ),
          ),
          backgroundColor: Colors.deepPurple, // Background color of the app bar
          elevation: 4, // Elevation for a subtle shadow effect
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.black,
              onPressed: () {
                // Logout functionality
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_img2.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageQuestionsScreen(),
                      ),
                    );
                  },
                  child: const Text('Manage Questions'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewResultPage(),
                      ),
                    );
                  },
                  child: const Text('View Result'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
