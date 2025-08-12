// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayQuestionPage extends StatefulWidget {
  final String category;

  const DisplayQuestionPage({super.key, required this.category});

  @override
  _DisplayQuestionPageState createState() => _DisplayQuestionPageState();
}

class _DisplayQuestionPageState extends State<DisplayQuestionPage> {
  QuerySnapshot<Map<String, dynamic>>? _questionsSnapshot;
  String? _selectedQuestionId;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection(widget.category).get();
      setState(() {
        _questionsSnapshot = snapshot;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching questions: $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Question'),
            content:
                const Text('Are you sure you want to delete this question?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  await FirebaseFirestore.instance
                      .collection(widget.category)
                      .doc(questionId)
                      .delete();
                  // ignore: avoid_print
                  print('Question deleted successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question deleted'),
                    ),
                  );
                  // Refresh the page after deletion
                  fetchQuestions();
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting question: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Questions'),
        automaticallyImplyLeading: false,
        actions: _selectedQuestionId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteQuestion(_selectedQuestionId!);
                  },
                ),
              ]
            : [],
      ),
      body: _questionsSnapshot != null
          ? _questionsSnapshot!.docs.isNotEmpty
              ? ListView.builder(
                  itemCount: _questionsSnapshot!.docs.length,
                  itemBuilder: (context, index) {
                    final question = _questionsSnapshot!.docs[index].data();
                    final questionId = _questionsSnapshot!.docs[index].id;

                    // Check if the question has an image URL
                    final hasImage = question.containsKey('Image URL') &&
                        question['Image URL'] != null &&
                        question['Image URL'].toString().isNotEmpty;

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectedQuestionId = questionId;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question: ${question['Question'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (hasImage)
                              Center(
                                child: SizedBox(
                                  height: 100, // Adjust height as needed
                                  child: Image.network(
                                    question['Image URL'] as String,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (question['Option A'] != null &&
                                question['Option A'].isNotEmpty)
                              Text('Option A: ${question['Option A']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            if (question['Option B'] != null &&
                                question['Option B'].isNotEmpty)
                              Text('Option B: ${question['Option B']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            if (question['Option C'] != null &&
                                question['Option C'].isNotEmpty)
                              Text('Option C: ${question['Option C']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            if (question['Option D'] != null &&
                                question['Option D'].isNotEmpty)
                              Text('Option D: ${question['Option D']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            Text(
                              'Correct Answer: ${question['Correct ans'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Explanation: ${question['Explanation'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text('No questions found.'))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
