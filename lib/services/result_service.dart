import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/result_model.dart';

class ResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save result for a quiz
  Future<void> saveResult(ResultModel result) async {
    try {
      await _firestore
          .collection('results')
          .doc(result.userId)
          .collection('quizzes')
          .doc(result.quizId)
          .set(result.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error saving result: $e");
    }
  }

  /// Get all results of a specific user
  Stream<List<ResultModel>> getUserResults(String userId) {
    return _firestore
        .collection('results')
        .doc(userId)
        .collection('quizzes')
        .orderBy('attemptedAt', descending: true) // match field name in model
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResultModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get all results for a specific quiz (admin use)
  Stream<List<ResultModel>> getQuizResults(String quizId) {
    return _firestore
        .collectionGroup('quizzes')
        .where('quizId', isEqualTo: quizId)
        .orderBy('attemptedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResultModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
