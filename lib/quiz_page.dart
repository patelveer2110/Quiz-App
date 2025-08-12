// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final String subject;
  final List<Map<String, dynamic>>? questions;

  const QuizPage(this.subject, this.questions, {super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Timer timer;
  int timeLeft = 10;
  late List<bool> displayedQues;
  int currentQuestionIndex = -1;
  int count = 0;
  late int noOfQuestions;
  late int score = 0;
  late int numberOfQuestions; // Added
  late int timeDuration;

  bool navigating = false;

  Map<String, dynamic> quizData = {
    'questions': [],
    'finalScore': 0,
  };

  @override
  void initState() {
    super.initState();
    // Fetch number of questions and timer duration from Firestore
    fetchUserData().then((userData) {
      setState(() {
        numberOfQuestions = userData['numberOfQuestions'] ?? 5;
        noOfQuestions = widget.questions!.length;
        displayedQues = List.generate(noOfQuestions, (_) => false);
        currentQuestionIndex = Random().nextInt(noOfQuestions);
        displayedQues[currentQuestionIndex] = true;
        count++;
        timeDuration =
            userData['timerDuration'] ?? 10; // Set the timer duration
        startTimer();
      });
    }).catchError((error) {
      // Handle error fetching user data
      print('Error fetching user data: $error');
      // Fallback to default values
      setState(() {
        numberOfQuestions = 5;
        noOfQuestions = widget.questions!.length;
        displayedQues = List.generate(noOfQuestions, (_) => false);
        currentQuestionIndex = Random().nextInt(noOfQuestions);
        displayedQues[currentQuestionIndex] = true;
        count++;
        timeDuration = 10; // Set a default timer duration
        startTimer();
      });
    });
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data() as Map<String, dynamic>; // Return user data as a map
    }
    return {}; // Return an empty map if user is not found
  }

  Future<int> fetchNumberOfQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc['numberOfQuestions'] ?? 5;
    }
    return 5;
  }

  void startTimer() {
    const duration = Duration(seconds: 1);
    timeLeft = timeDuration;

    timer = Timer.periodic(duration, (Timer t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;

          if (timeLeft == 0) {
            // moveToNextQuestion();
            checkAnswer(
                '', currentQuestionIndex); // Call checkAnswer with empty option
          }
        }
      });
    });
  }

  void checkAnswer(String option, int questionIndex) {
    print("Checking answer");
    if (widget.questions != null &&
        currentQuestionIndex < widget.questions!.length) {
      Map<String, dynamic>? currentQuestion =
          widget.questions![currentQuestionIndex];
      // ignore: unnecessary_null_comparison
      if (currentQuestion != null) {
        String question = currentQuestion['Question'] ?? '';
        String correctAns = currentQuestion['Correct ans'] ?? '';
        String explanation = currentQuestion['Explanation'] ?? '';
        String imageURL = currentQuestion['Image URL'] ?? '';

        if (question.isNotEmpty &&
            correctAns.isNotEmpty &&
            explanation.isNotEmpty) {
          Map<String, dynamic> questionData = {
            'Question': question,
            'Correct ans': correctAns,
            'Explanation': explanation,
            'Option A': currentQuestion['Option A'] ?? '',
            'Option B': currentQuestion['Option B'] ?? '',
            'Option C': currentQuestion['Option C'] ?? '',
            'Option D': currentQuestion['Option D'] ?? '',
            'Selected Option':
                option.isNotEmpty ? option : 'NOT selected anything',
            'Image URL': imageURL,
          };
          quizData['questions'].add(questionData);
          if (option.isNotEmpty && correctAns == option) {
            score++;
          } else {
            // If the timer runs out without selecting an option, set the selected option as null
            questionData['Selected Option'] = null;
          }
          moveToNextQuestion();
        }
      }
    }
  }

  void moveToNextQuestion() {
    setState(() {
      if (count < numberOfQuestions) {
        int temp = currentQuestionIndex; // Store the current index
        while (displayedQues[temp] == true) {
          temp = Random().nextInt(widget.questions!.length);
        }
        count++;
        currentQuestionIndex = temp;
        displayedQues[temp] = true;
        timeLeft = timeDuration;
      } else {
        timer.cancel();
        navigating = true;
        _navigateToResultPage();
      }
    });
  }

  void _navigateToResultPage() async {
    quizData['finalScore'] = score;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String subjectPrefix =
          widget.subject.toLowerCase(); // Get the subject name in lowercase
      String docId =
          '$subjectPrefix-${DateTime.now().millisecondsSinceEpoch}'; // Prefix with subject name and timestamp
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('quizData')
          .doc(docId)
          .set(quizData);
    }
    navigating = false;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(score, numberOfQuestions),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          widget.subject,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '$timeLeft secs',
                  style: TextStyle(
                    fontSize: 16,
                    color: timeLeft <= 3 ? Colors.red : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'SCORE: $score/$numberOfQuestions',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Question $count:',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.questions![currentQuestionIndex]['Question'],
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (widget.questions![currentQuestionIndex]['Image URL'] !=
                      null &&
                  widget.questions![currentQuestionIndex]['Image URL'] != '')
                SizedBox(
                  height: 150, // Adjust height as needed
                  child: Image.network(
                    widget.questions![currentQuestionIndex]['Image URL']
                        as String,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      String optionKey =
                          String.fromCharCode('A'.codeUnitAt(0) + index);
                      String option = widget.questions![currentQuestionIndex]
                          ['Option $optionKey'];
                      // Check if option is not null or empty
                      // ignore: unnecessary_null_comparison
                      if (option != null && option.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                checkAnswer(
                                    'Option $optionKey', currentQuestionIndex);
                                timeLeft = timeDuration; // Corrected typo here
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox
                            .shrink(); // Don't display anything for null or empty options
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
