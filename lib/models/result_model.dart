import 'package:cloud_firestore/cloud_firestore.dart';

class ResultModel {
  final String id; // Firestore document ID
  final String quizId;
  final String quizTitle; // optional, to display in UI
  final String userId;
  final int score;
  final int totalQuestions;
  final DateTime attemptedAt;

  ResultModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.attemptedAt,
  });

  // From Firestore
  factory ResultModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ResultModel(
      id: documentId,
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? 'Untitled Quiz',
      userId: data['userId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      attemptedAt: (data['attemptedAt'] is Timestamp)
          ? (data['attemptedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['attemptedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'attemptedAt': Timestamp.fromDate(attemptedAt),
    };
  }
}
