import 'package:flutter/material.dart';
import 'package:quiz/screens/do_this.dart'; // Import the DoThisPage file

class ManageQuestionsScreen extends StatelessWidget {
  const ManageQuestionsScreen({super.key});

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
          title: const Text('Manage Questions'),
          backgroundColor:
              Colors.deepPurple, // Match the color with AdminScreen
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome! Select a Subject to Add or Display Questions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoThisPage(
                        category: '1', // Pass the category number to DoThisPage
                      ),
                    ),
                  );
                },
                child: const Text('NLP'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoThisPage(
                        category: '2', // Pass the category number to DoThisPage
                      ),
                    ),
                  );
                },
                child: const Text('ML'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoThisPage(
                        category: '3', // Pass the category number to DoThisPage
                      ),
                    ),
                  );
                },
                child: const Text('BDA'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoThisPage(
                        category: '4', // Pass the category number to DoThisPage
                      ),
                    ),
                  );
                },
                child: const Text('BLOC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
