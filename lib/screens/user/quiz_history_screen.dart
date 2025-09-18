import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/result_model.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  Stream<List<ResultModel>> _getUserResults() {
 final userEmail = FirebaseAuth.instance.currentUser?.email;
if (userEmail == null) return const Stream.empty();

return FirebaseFirestore.instance
    .collectionGroup('participants')
    .where('userEmail', isEqualTo: userEmail)
    .orderBy('timestamp', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) {
          final data = doc.data();
          return ResultModel.fromMap(data, doc.id);
        })
        .toList());

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz History")),
      body: StreamBuilder<List<ResultModel>>(
        stream: _getUserResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading history"));
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const Center(child: Text("No quiz attempts yet."));
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(result.quizTitle),
                  subtitle: Text(
                    "Score: ${result.score}/${result.totalQuestions} | Date: ${result.attemptedAt.toLocal()}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      Navigator.pushNamed(context, '/resultDetail',
                          arguments: result);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
