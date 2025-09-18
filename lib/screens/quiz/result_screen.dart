import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String quizId;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.total,
    required this.quizId,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    saveResult();
  }

  Future<void> saveResult() async {
    setState(() => isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('quizResults')
            .doc(widget.quizId)
            .collection('participants')
            .doc(user.uid)
            .set({
          'score': widget.score,
          'total': widget.total,
          'percentage': (widget.score / widget.total) * 100,
          'timestamp': FieldValue.serverTimestamp(),
          'userEmail': user.email,
        });
      }
    } catch (e) {
      debugPrint('Error saving result: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (widget.score / widget.total) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: Center(
        child: isSaving
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You scored ${widget.score} out of ${widget.total}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Percentage: ${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
