import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user?.email ?? 'No email'),
            subtitle: const Text('Logged in user'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            subtitle: const Text('Light / Dark Mode'),
            onTap: () {
              // TODO: Implement theme change
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Quiz History'),
            onTap: () {
              Navigator.pushNamed(context, '/quizHistory');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
