import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import 'create_quiz_screen.dart';
import 'quiz_report_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  const ManageQuizzesScreen({Key? key}) : super(key: key);

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final QuizService _quizService = QuizService();
  final String _adminId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Quizzes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<QuizModel>>(
        stream: _quizService.getQuizzesByAdmin(_adminId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No quizzes yet"));
          }

          final quizzes = snapshot.data!;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(quiz.title),
                  subtitle: Text(
                    "Subject: ${quiz.subject} | Code: ${quiz.code}",
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "delete") {
                        await _quizService.deleteQuiz(quiz.quizId);
                      } else if (value == "report") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizReportScreen(quizId: quiz.quizId),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "report",
                        child: Text("View Report"),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
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
