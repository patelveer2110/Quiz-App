import 'package:flutter/material.dart';
import 'package:quiz/screens/selection_page.dart';
// import 'pack'

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultPage(this.score, this.totalQuestions, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal, // Set app bar color
      ),
      backgroundColor: const Color.fromARGB(
          255, 241, 235, 235), // Set background color to white
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Quiz Finished!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score: $score/$totalQuestions',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/congrats.png', // Add a congratulations image
                width: 250,
                height: 80,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectionPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Back to Main page',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
