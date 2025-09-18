class QuizModel {
  final String quizId;
  final String title;
  final String subject;
  final String code; // Generated unique code
  final String createdBy; // Admin UID
  final int numberOfQuestions;
  final int pointsPerQuestion;
  final DateTime startTime;
  final DateTime deadline;

  QuizModel({
    required this.quizId,
    required this.title,
    required this.subject,
    required this.code,
    required this.createdBy,
    required this.numberOfQuestions,
    required this.pointsPerQuestion,
    required this.startTime,
    required this.deadline,
  });

  // From Firestore
  factory QuizModel.fromMap(Map<String, dynamic> data, String documentId) {
    return QuizModel(
      quizId: documentId,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      code: data['code'] ?? '',
      createdBy: data['createdBy'] ?? '',
      numberOfQuestions: data['numberOfQuestions'] ?? 0,
      pointsPerQuestion: data['pointsPerQuestion'] ?? 0,
      startTime: DateTime.parse(data['startTime']),
      deadline: DateTime.parse(data['deadline']),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'code': code,
      'createdBy': createdBy,
      'numberOfQuestions': numberOfQuestions,
      'pointsPerQuestion': pointsPerQuestion,
      'startTime': startTime.toIso8601String(),
      'deadline': deadline.toIso8601String(),
    };
  }
}
