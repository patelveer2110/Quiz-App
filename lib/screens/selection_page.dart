// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz/screens/settings.dart';
import 'package:quiz/view_attended_questions.dart';
import 'package:quiz/subject_selection_page.dart';
import 'package:image_picker/image_picker.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key});

  Future<void> _uploadProfilePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload the image file to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload task to complete
      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded file
        final photoUrl = await storageRef.getDownloadURL();

        // Update the user's photoUrl in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'photoUrl': photoUrl}, SetOptions(merge: true));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo uploaded successfully!'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Main Page'),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.tealAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      drawer: Drawer(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var userData = snapshot.data!.data() as Map?;
            String? photoUrl = userData?['photoUrl'];
            String? username = userData?['username'];

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                  ),
                  accountName: Text(
                    username ?? 'Student',
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  accountEmail: null,
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      _showProfileDialog(context, photoUrl, username);
                    },
                    child: CircleAvatar(
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/images/logo.jpg')
                              as ImageProvider<Object>,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('View previous quiz'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewAttendedQuestionsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to the Quiz App!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectSelectionPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Select Subject',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProfileDialog(
      BuildContext context, String? photoUrl, String? username) async {
    String newUsername = username ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : const AssetImage('assets/images/logo.jpg')
                            as ImageProvider<Object>,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => newUsername = value,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: newUsername),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({'username': newUsername});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Username updated successfully!'),
                          ),
                        );
                      }
                    },
                    child: const Text('Edit Username'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _uploadProfilePhoto(context);
                    },
                    child: const Text('Change Profile Photo'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ViewProfilePhotoScreen extends StatelessWidget {
  final String? photoUrl;

  const ViewProfilePhotoScreen(this.photoUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Photo'),
      ),
      body: Center(
        child: photoUrl != null
            ? Image.network(
                photoUrl!,
                fit: BoxFit.contain,
              )
            : const Text('No photo available'),
      ),
    );
  }
}
