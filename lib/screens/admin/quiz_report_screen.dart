import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QuizReportScreen extends StatefulWidget {
  final String quizId;
  const QuizReportScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizReportScreen> createState() => _QuizReportScreenState();
}

class _QuizReportScreenState extends State<QuizReportScreen> {
  bool _isExporting = false;

  Future<void> _exportToCSV(List<Map<String, dynamic>> data) async {
    setState(() => _isExporting = true);

    List<List<dynamic>> csvData = [
      ["User Name", "Email", "Score", "Date"]
    ];

    for (var row in data) {
      csvData.add([
        row["userName"],
        row["email"],
        row["score"].toString(),
        row["date"].toDate().toString()
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    final dir = await getExternalStorageDirectory();
    final file = File("${dir!.path}/quiz_${widget.quizId}_report.csv");
    await file.writeAsString(csv);

    setState(() => _isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("CSV exported: ${file.path}")),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Quiz Report"),
      actions: [
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Colors.white),
          )
      ],
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("quizResults")
          .doc(widget.quizId)
          .collection("participants")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No results yet"));
        }

        final results = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final res = results[index];
                  final date = (res['timestamp'] as Timestamp?)?.toDate();
                  return ListTile(
                    title: Text(res["userName"] ?? "Unknown User"),
                    subtitle: date != null
                        ? Text(
                            "Attempted on: ${date.toLocal().toString().split('.')[0]}")
                        : null,
                    trailing: Text("${res["score"]} / ${res["total"]}"),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download CSV"),
                onPressed: () => _exportToCSV(results),
              ),
            )
          ],
        );
      },
    ),
  );
}

}
