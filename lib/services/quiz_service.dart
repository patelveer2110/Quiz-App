import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

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

  // Add single question to quiz
  Future<bool> addQuestion({
    required String quizId,
    required String question,
    required List<String> options,
    required int correctOptionIndex,
  }) async {
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
      return true;
    } catch (e) {
      print('Add question error: $e');
      return false;
    }
  }

  // Upload questions from Excel
  Future<bool> addQuestionsFromExcel(String quizId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) return false; // User canceled

      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      Sheet sheet = excel.sheets.values.first;

      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        var row = sheet.row(rowIndex);
        String question = row[0]?.value.toString() ?? "";
        List<String> options = [
          row[1]?.value.toString() ?? "",
          row[2]?.value.toString() ?? "",
          row[3]?.value.toString() ?? "",
          row[4]?.value.toString() ?? "",
        ];
        int correctIndex = int.tryParse(row[5]?.value.toString() ?? "0") ?? 0;

        if (question.isEmpty || options.any((o) => o.isEmpty)) continue;

        await addQuestion(
          quizId: quizId,
          question: question,
          options: options,
          correctOptionIndex: correctIndex,
        );
      }

      return true;
    } catch (e) {
      print("Excel upload error: $e");
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
