class QuestionModel {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // index of correct answer in options list
  final String? imageUrl; // optional image for question

  QuestionModel({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.imageUrl,
  });

  // From Firestore
  factory QuestionModel.fromMap(Map<String, dynamic> data, String documentId) {
    return QuestionModel(
      questionId: documentId,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correctOptionIndex'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'imageUrl': imageUrl,
    };
  }
}
