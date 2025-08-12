import 'package:flutter/material.dart';
import 'package:quiz/screens/add_questions.dart';
import 'package:quiz/screens/display_questions.dart';

class DoThisPage extends StatelessWidget {
  final String category;

  const DoThisPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Do This'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to AddQuestionPage for the specified category
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddQuestionScreen(category: category),
                  ),
                );
              },
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to DisplayQuestionPage for the specified category
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DisplayQuestionPage(category: category),
                  ),
                );
              },
              child: const Text('Display Question'),
            ),
          ],
        ),
      ),
    );
  }
}
