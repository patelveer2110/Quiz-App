// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionDetailsPage extends StatelessWidget {
  final String docId;
  final String userId;

  const QuestionDetailsPage(
      {super.key, required this.docId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('quizData')
            .doc(docId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Question not found.'));
          }

          var quizData = snapshot.data!.data() as Map<String, dynamic>;
          var questions = quizData['questions'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: questions.map((questionData) {
                bool isCorrect = questionData['Selected Option'] ==
                    questionData['Correct ans'];
                Color containerColor = isCorrect
                    ? const Color.fromRGBO(
                        144, 199, 147, 0.8) // Slightly transparent green
                    : const Color.fromRGBO(
                        219, 162, 158, 0.8); // Slightly transparent red

                // Check if options are not null before displaying them
                List<Widget> optionWidgets = [];
                for (int i = 0; i < 4; i++) {
                  String optionKey =
                      'Option ${String.fromCharCode('A'.codeUnitAt(0) + i)}';
                  if (questionData[optionKey] != null &&
                      questionData[optionKey].isNotEmpty) {
                    optionWidgets
                        .add(Text('$optionKey: ${questionData[optionKey]}'));
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: containerColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question: ${questionData['Question']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      if (questionData['Image URL'] != null &&
                          questionData['Image URL'].isNotEmpty) ...[
                        // Check if an image URL exists and display it
                        const SizedBox(height: 8.0),
                        Image.network(
                          questionData['Image URL'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ],
                      const SizedBox(height: 8.0),
                      Text('Correct Answer: ${questionData['Correct ans']}'),
                      const SizedBox(height: 8.0),
                      Text('Explanation: ${questionData['Explanation']}'),
                      const SizedBox(height: 8.0),

                      // Display options if they are not null
                      ...optionWidgets,
                      const SizedBox(height: 8.0),
                      Text(
                          'Selected Option: ${questionData['Selected Option']}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
