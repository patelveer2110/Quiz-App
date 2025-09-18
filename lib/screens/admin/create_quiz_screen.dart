import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/quiz_service.dart';
import '../../services/qr_service.dart';
import 'add_question_screen.dart'; // Don't forget to import this!

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({Key? key}) : super(key: key);

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _numQuestionsController = TextEditingController();
  final _pointsController = TextEditingController();
  DateTime? _startTime;
  DateTime? _deadline;
  bool _loading = false;
  String? _quizCode;

  final _quizService = QuizService();
  final _qrService = QRService();

  Future<void> _pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        DateTime finalDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() {
          if (isStart) {
            _startTime = finalDateTime;
          } else {
            _deadline = finalDateTime;
          }
        });
      }
    }
  }

  Future<void> _createQuiz() async {
    if (_titleController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _numQuestionsController.text.isEmpty ||
        _pointsController.text.isEmpty ||
        _startTime == null ||
        _deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => _loading = true);

    int numQuestions = int.parse(_numQuestionsController.text.trim());

    String? quizId = await _quizService.createQuiz(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      createdBy: FirebaseAuth.instance.currentUser!.uid,
      numberOfQuestions: numQuestions,
      pointsPerQuestion: int.parse(_pointsController.text),
      startTime: _startTime!,
      deadline: _deadline!,
    );

    setState(() {
      _loading = false;
    });

    if (quizId != null) {
      debugPrint("Quiz created with ID: $quizId");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Quiz Created")));
      // String? code = await _quizService.getQuizCode(quizId);
      debugPrint("Navigating to AddQuestionScreen with quizId: $quizId");
     await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AddQuestionScreen(quizId: quizId, totalQuestions: numQuestions),
        ),
      );
      debugPrint("Returned from AddQuestionScreen");
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create quiz")));
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building CreateQuizScreen...");
    return Scaffold(
      appBar: AppBar(title: const Text("Create Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Quiz Title"),
            ),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject Name"),
            ),
            TextField(
              controller: _numQuestionsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Questions",
              ),
            ),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Points per Question",
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDate(true),
                    child: const Text("Pick Start Time"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDate(false),
                    child: const Text("Pick Deadline"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createQuiz,
                    child: const Text("Create Quiz"),
                  ),
            if (_quizCode != null) ...[
              const SizedBox(height: 20),
              const Text("Quiz Created! Share this QR:"),
              _qrService.qrWidget(_quizCode ?? ""),
            ],
          ],
        ),
      ),
    );
  }
}
