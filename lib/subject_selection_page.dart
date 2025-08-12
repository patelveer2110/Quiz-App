// ignore_for_file: use_build_context_synchronously, avoid_print, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'quiz_page.dart';

class SubjectSelectionPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Text('Select a Subject'),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.tealAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF1EBEB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SubjectButton(
                "NLP",
                () async {
                  navigateToQuizPage(context, "NLP", '1');
                },
                'assets/images/NLPimage.jpg',
                width: 150.0,
                height: 150.0,
              ),
              const SizedBox(height: 50),
              SubjectButton(
                "BDA",
                () async {
                  navigateToQuizPage(context, "BDA", '3');
                },
                'assets/images/BDAimage.jpg',
                width: 150.0,
                height: 150,
              ),
              const SizedBox(height: 50),
              SubjectButton(
                "ML",
                () async {
                  navigateToQuizPage(context, "ML", '2');
                },
                'assets/images/MLimage.jpeg',
                width: 150.0,
                height: 150.0,
              ),
              const SizedBox(height: 50),
              SubjectButton(
                "Bloc",
                () async {
                  navigateToQuizPage(context, "BLOC", '4');
                },
                'assets/images/BLOCimage.png',
                width: 150.0,
                height: 150,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToQuizPage(
      BuildContext context, String subject, String subjectCode) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection(subjectCode).get();
    List<Map<String, dynamic>> list =
        querySnapshot.docs.map((e) => e.data()).toList();
    if (list.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizPage(subject, list),
        ),
      );
    } else {
      // Handle case where no questions are found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No questions found for $subject"),
        ),
      );
    }
  }
}

class SubjectButton extends StatelessWidget {
  final String subject;
  final VoidCallback onPressed;
  final String imagePath;
  final double width;
  final double height;

  const SubjectButton(this.subject, this.onPressed, this.imagePath,
      {this.width = 150.0, this.height = 150.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              padding: EdgeInsets.zero,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          subject,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
