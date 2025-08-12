// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_screen.dart'; // Import your AdminScreen file

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = false;
  var _enteredEmail = '';
  var _enteredPassword = '';

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    _firebase.authStateChanges().listen((user) {
      if (user != null) {
        if (user.email != null && user.email!.endsWith('admin.com')) {
          // Navigate to the admin screen if the user is an admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminScreen()),
          );
        } else {
          // Navigate to another screen for non-admin users
          // For example, you can navigate to the student's subject selection page
        }
      }
    });
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();
    // ignore: avoid_print
    print(isValid);

    _form.currentState!.save();
    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        // Check if the logged-in user's email domain is admin.com
        if (_enteredEmail.endsWith('admin.com')) {
          // Navigate to the admin screen if the user is an admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminScreen()),
          );
          return; // Stop further execution
        }
      } else {
        // Create a new user with email and password
        await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        // Get the current user after creating the account
        final user = _firebase.currentUser;

        // Check if the signed-up user's email domain is admin.com
        if (_enteredEmail.endsWith('admin.com')) {
          // Navigate to the admin screen if the user is an admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminScreen()),
          );
          return; // Stop further execution
        }

        // Add the UID to the "users" collection in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid) // Use the UID as the document ID
            .set({
          'email': _enteredEmail,
          // You can add more user data here as needed
        });

        // Navigate to another screen for non-admin users
        // For example, you can navigate to the student's subject selection page
      }

      // If the user is not an admin or if it's a login operation for a non-admin, do something else
      // For example, you can navigate to another screen here
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // .......
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Make the background transparent
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/logo.jpg'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal, // Use teal color
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Ink(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                _isLogin ? 'Login' : 'Signup',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Create an Account'
                                : 'I already have an Account',
                            style: const TextStyle(
                              color: Colors.teal, // Use teal color
                            ),
                          ),
                        ),
                      ],
                    ),
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
