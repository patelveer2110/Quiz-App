import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>> quizHistory = [];

  @override
  void initState() {
    super.initState();
    fetchQuizHistory();
  }

Future<void> fetchQuizHistory() async {
  if (user == null) return;

  try {
    // Fetch all quiz results under this user
    final quizResultsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('quizResults')
        .get();

    print("Total quizzes found: ${quizResultsSnapshot.docs.length}");

    List<Map<String, dynamic>> tempHistory = [];

    for (var quizDoc in quizResultsSnapshot.docs) {
      // quizDoc.data() should contain score, total, percentage, timestamp, quizTitle
      tempHistory.add({
        'quizId': quizDoc.id,
        'score': quizDoc['score'],
        'total': quizDoc['total'],
        'percentage': quizDoc['percentage'],
        'timestamp': quizDoc['timestamp'],
        'quizTitle': quizDoc['quizTitle'] ?? quizDoc.id,
      });
    }

    // Sort by most recent
    tempHistory.sort((a, b) {
      Timestamp t1 = a['timestamp'] ?? Timestamp.now();
      Timestamp t2 = b['timestamp'] ?? Timestamp.now();
      return t2.compareTo(t1);
    });

    setState(() {
      quizHistory = tempHistory;
      isLoading = false;
    });
  } catch (e) {
    debugPrint("Error fetching quiz history: $e");
    setState(() => isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizHistory.isEmpty
              ? const Center(child: Text("No quizzes attended yet"))
              : ListView.builder(
                  itemCount: quizHistory.length,
                  itemBuilder: (context, index) {
                    final quiz = quizHistory[index];
                    final date = (quiz['timestamp'] as Timestamp?)?.toDate();

                  return Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quiz['quizTitle'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
            "Score: ${quiz['score']} / ${quiz['total']} (${quiz['percentage'].toStringAsFixed(1)}%)"),
        if (date != null)
          Text(
            "Attempted on: ${date.toLocal().toString().split('.')[0]}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    ),
  ),
);

                  },
                ),
    );
  }
}
