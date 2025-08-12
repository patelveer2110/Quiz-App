// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz/question_details_page.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  Future<void> deleteDocument(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('quizData')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('quizData')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No attended questions yet.'));
          }

          // Display the list of document IDs with finalScore
          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot<Map<String, dynamic>> doc) {
              var data = doc.data()!; // Cast data to Map
              var finalScore =
                  data['finalScore']; // Get finalScore from data map
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(doc.id), // Display the document ID
                    ),
                    Text(
                      'Score: $finalScore', // Display finalScore at the right corner
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green, // You can adjust color as needed
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuestionDetailsPage(docId: doc.id, userId: userId),
                    ),
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Document?'),
                      content: const Text(
                          'Are you sure you want to delete this document?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteDocument(doc.id, context);
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
