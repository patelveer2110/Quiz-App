import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/question_model.dart';
import 'result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final String quizId;

  const QuizPlayScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  String quizTitle = ""; // <-- added quiz title

  @override
  void initState() {
    super.initState();
    fetchQuiz();
  }

  Future<void> fetchQuiz() async {
    try {
      // Fetch quiz document to get title
      final quizDoc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      quizTitle = quizDoc.data()?['title'] ?? "Quiz";

      // Fetch questions
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .get();

      questions = snapshot.docs
          .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching quiz: $e');
      setState(() => isLoading = false);
    }
  }

  void checkAnswer(String selectedAnswer) {
    final correctAnswer = questions[currentQuestionIndex]
        .options[questions[currentQuestionIndex].correctOptionIndex];

    if (selectedAnswer == correctAnswer) score++;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: score,
            total: questions.length,
            quizId: widget.quizId,
            quizTitle: quizTitle, // <-- pass fetched title
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: $quizTitle'), // <-- show title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              question.question, // updated field
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (question.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(question.imageUrl!),
              ),
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  child: Text(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
