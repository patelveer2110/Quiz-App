class QuestionModel {
  final String questionId;
  final String question; // renamed from questionText
  final List<String> options;
  final int correctOptionIndex;
  final String? imageUrl;

  QuestionModel({
    required this.questionId,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.imageUrl,
  });

  // From Firestore
  factory QuestionModel.fromMap(Map<String, dynamic> data, String documentId) {
    return QuestionModel(
      questionId: documentId,
      question: data['question'] ?? '', // updated field name
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correctOptionIndex'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'question': question, // updated field name
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'imageUrl': imageUrl,
    };
  }
}
