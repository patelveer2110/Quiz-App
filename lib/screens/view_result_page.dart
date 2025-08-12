import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz/screens/user_details_page.dart';

class ViewResultPage extends StatelessWidget {
  const ViewResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User IDs in Firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of User IDs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Process snapshot data for user IDs
                  List<QueryDocumentSnapshot> userDocuments =
                      snapshot.data!.docs;
                  List<String> userIds =
                      userDocuments.map((doc) => doc.id).toList();

                  return ListView.builder(
                    itemCount: userIds.length,
                    itemBuilder: (context, index) {
                      String userId = userIds[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to another page when user ID is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailsPage(userId: userId),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title: Text('User ID: $userId'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
