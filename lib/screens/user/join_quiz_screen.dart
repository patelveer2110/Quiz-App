import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../services/quiz_service.dart';
import '../quiz/quiz_play_screen.dart';

class JoinQuizScreen extends StatefulWidget {
  const JoinQuizScreen({Key? key}) : super(key: key);
  
  @override
  State<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends State<JoinQuizScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
    @override
  void initState() {
    debugPrint("JoinQuizScreen initState called");
    
    // print("some message");
stdout.writeln("force flushed message");  // ✅ when screen first created
    super.initState();
  }
Future<void> _joinQuiz() async {
  final code = _codeController.text.trim();
   debugPrint("Entered code: $code"); 
  if (code.isEmpty) {
    debugPrint("No code entered");
    setState(() => _errorMessage = "Please enter a quiz code");
    return;
  }

  setState(() {
    _loading = true;
    _errorMessage = null;
  });

  try {
    debugPrint(  "Joining quiz with code: $code");
    final querySnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .where('code', isEqualTo: code)
        .get();

    if (querySnapshot.docs.isEmpty) {
      debugPrint(code);
      setState(() => _errorMessage = "No quiz found with that code");
    } else {
      final doc = querySnapshot.docs.first;
     Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => QuizPlayScreen(quizId: doc.id),
  ),
);

    }
  } catch (e) {
    setState(() => _errorMessage = "Error: ${e.toString()}");
  }

  setState(() => _loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Enter Quiz Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 15),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Join"),
                    onPressed: _joinQuiz,
                  ),
          ],
        ),
      ),
    );
  }
}
