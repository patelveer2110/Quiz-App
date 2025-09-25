import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user/user_dashboard.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String quizId;
  final String quizTitle; // New parameter to hold quiz title

  const ResultScreen({
    Key? key,
    required this.score,
    required this.total,
    required this.quizId,
    required this.quizTitle,
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
      // Fetch username from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      final quizRef = FirebaseFirestore.instance
          .collection('quizResults')
          .doc(widget.quizId)
          .collection('participants')
          .doc(user.uid);

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('quizResults')
          .doc(widget.quizId);

      // Save under quizResults for admin reporting
      await quizRef.set({
        'score': widget.score,
        'total': widget.total,
        'percentage': (widget.score / widget.total) * 100,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': user.email,
        'userName': userName, // fetched from Firestore
      });

      // Save under users for user-specific history
      await userRef.set({
        'score': widget.score,
        'total': widget.total,
        'percentage': (widget.score / widget.total) * 100,
        'timestamp': FieldValue.serverTimestamp(),
        'quizTitle': widget.quizTitle,
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const UserDashboard(), // your dashboard screen
      ),
      (route) => false, // removes all previous routes
    );
  },
  child: const Text('Back to Dashboard'),
),
                  ],
                ),
              ),
      ),
    );
  }
}
