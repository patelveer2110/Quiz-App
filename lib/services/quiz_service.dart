import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import 'dart:math';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate random quiz code
  String _generateQuizCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // Create new quiz
  Future<String?> createQuiz({
    required String title,
    required String subject,
    required String createdBy,
    required int numberOfQuestions,
    required int pointsPerQuestion,
    required DateTime startTime,
    required DateTime deadline,
  }) async {
    try {
      String code = _generateQuizCode();

      DocumentReference docRef = await _firestore.collection('quizzes').add({
        'title': title,
        'subject': subject,
        'code': code,
        'createdBy': createdBy,
        'numberOfQuestions': numberOfQuestions,
        'pointsPerQuestion': pointsPerQuestion,
        'startTime': startTime.toIso8601String(),
        'deadline': deadline.toIso8601String(),
      });

      return docRef.id;
    } catch (e) {
      print("Create Quiz Error: $e");
      return null;
    }
  }

  // Add question to quiz
Future<bool> addQuestion({
  required String quizId,
  required String question,
  required List<String> options,
  required int correctOptionIndex,
}) async {
  print("Adding question to quiz: $quizId");
  print("Question: $question");
  print("Options: $options");
  print("Correct option index: $correctOptionIndex");
  try {
    await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .add({
          'question': question,
          'options': options,
          'correctOptionIndex': correctOptionIndex,
        });
    print("Question added successfully");
    return true;
  } catch (e) {
    print('Add question error: $e');
    return false;
  }
}



  // Get quiz by code
  Future<QuizModel?> getQuizByCode(String code) async {
    QuerySnapshot snap = await _firestore
        .collection('quizzes')
        .where('code', isEqualTo: code)
        .get();

    if (snap.docs.isNotEmpty) {
      var doc = snap.docs.first;
      return QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get all quizzes by admin
  Stream<List<QuizModel>> getQuizzesByAdmin(String adminId) {
    return _firestore
        .collection('quizzes')
        .where('createdBy', isEqualTo: adminId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => QuizModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

  
}
