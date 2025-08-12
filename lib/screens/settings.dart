// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:just_audio/just_audio.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State {
  // Initialize Firebase
  late final Future<FirebaseApp> _firebaseInitialization =
      Firebase.initializeApp();

  // Initialize variables for settings
  late bool isMusicOn = true; // Default music state
  late int timerDuration = 5; // Default timer duration
  late int numberOfQuestions = 5; // Default number of questions

  // Firestore reference
  late final CollectionReference _settingsCollection =
      FirebaseFirestore.instance.collection('users');

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load settings when the page initializes
  }

  // Function to load settings from Firestore
  Future<void> _loadSettings() async {
    try {
      final settingsDoc = await _settingsCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (settingsDoc.exists) {
        // If settings document exists, use its values
        setState(() {
          isMusicOn = settingsDoc['music'] ?? false;
          timerDuration = settingsDoc['timerDuration'] ?? 10;
          numberOfQuestions = settingsDoc['numberOfQuestions'] ?? 5;
        });
      }
    } catch (error) {
      print('Error loading settings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: FutureBuilder(
        future: _firebaseInitialization,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Music'),
                    value: isMusicOn,
                    onChanged: (value) {
                      setState(() {
                        isMusicOn = value;
                        _updateSettings();
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Timer Duration:'),
                      DropdownButton<int>(
                        value: timerDuration,
                        onChanged: (value) {
                          setState(() {
                            timerDuration = value!;
                            _updateSettings();
                          });
                        },
                        items: [5, 10, 15, 20].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value secs'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Number of Questions:'),
                      DropdownButton<int>(
                        value: numberOfQuestions,
                        onChanged: (value) {
                          setState(() {
                            numberOfQuestions = value!;
                            _updateSettings();
                          });
                        },
                        items: [5, 10, 15, 20].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Function to update settings in Firestore
  void _updateSettings() {
    _settingsCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
      'music': isMusicOn,
      'timerDuration': timerDuration,
      'numberOfQuestions': numberOfQuestions,
    }, SetOptions(merge: true)).then((_) {
      print('Settings updated successfully');
      // Play or stop the audio based on the isMusicOn variable
      if (isMusicOn) {
        _playAudio(); // Play audio
      } else {
        _stopAudio(); // Stop audio
      }
    }).catchError((error) {
      print('Failed to update settings: $error');
    });
  }

  void _playAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/quizaudio.mpeg');
      await _audioPlayer.play();
    } catch (e) {
      print('Failed to play audio: $e');
    }
  }

  void _stopAudio() {
    _audioPlayer.stop();
  }
}
