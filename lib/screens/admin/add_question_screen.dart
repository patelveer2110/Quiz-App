import 'package:flutter/material.dart';
import '../../services/quiz_service.dart';

class AddQuestionScreen extends StatefulWidget {
  final String quizId;
  final int totalQuestions;

  const AddQuestionScreen({
    Key? key,
    required this.quizId,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctOptionIndex = 0;
  bool _loading = false;

  int _questionsAdded = 0;

  Future<void> _addQuestion() async {
    debugPrint("Add question button pressed.");

    if (_questionController.text.isEmpty ||
        _optionControllers.any((c) => c.text.isEmpty)) {
      debugPrint("Validation failed: Some fields are empty.");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all question fields")));
      return;
    }

    setState(() {
      _loading = true;
    });
    debugPrint("Loading set to true, starting to add question...");

    bool success = await QuizService().addQuestion(
      quizId: widget.quizId,
      question: _questionController.text.trim(),
      options: _optionControllers.map((c) => c.text.trim()).toList(),
      correctOptionIndex: _correctOptionIndex,
    );

    debugPrint("QuizService.addQuestion returned: $success");

    setState(() {
      _loading = false;
    });
    debugPrint("Loading set to false.");

    if (success) {
      _questionsAdded++;
      debugPrint("Questions added so far: $_questionsAdded");

      if (_questionsAdded >= widget.totalQuestions) {
        debugPrint("All questions added. Navigating back...");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("All questions added!")));
        Navigator.pop(context); // or navigate elsewhere
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Question $_questionsAdded added")),
        );
        debugPrint("Clearing inputs for next question...");
        _questionController.clear();
        for (var c in _optionControllers) c.clear();
        setState(() {
          _correctOptionIndex = 0;
        });
      }
    } else {
      debugPrint("Failed to add question.");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add question")));
    }
  }

  @override
  void dispose() {
    debugPrint("Disposing controllers...");
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Questions")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${_questionsAdded + 1} of ${widget.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _questionController,
                        decoration: const InputDecoration(
                          labelText: "Question",
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<int>(
                            title: TextField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText: "Option ${index + 1}",
                              ),
                            ),
                            value: index,
                            groupValue: _correctOptionIndex,
                            onChanged: (value) {
                              setState(() {
                                _correctOptionIndex = value!;
                              });
                            },
                          ),
                        );
                      }),
                      const Spacer(),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: ElevatedButton(
                                onPressed: _addQuestion,
                                child: Text(
                                  _questionsAdded + 1 == widget.totalQuestions
                                      ? "Add Last Question"
                                      : "Add Question",
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
