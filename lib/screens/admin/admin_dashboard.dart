 import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'create_quiz_screen.dart';
import 'manage_quizzes_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  void _logout(BuildContext context) {
    debugPrint("🚪 Admin tapped logout");
    AuthService().signOut();
    debugPrint("✅ Admin signed out, redirecting to login screen");
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("📌 Building AdminDashboard screen");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildCard(
            context,
            title: "Create Quiz",
            icon: Icons.add_circle,
            onTap: () {
              debugPrint("➡️ Navigating to CreateQuizScreen");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  debugPrint("📌 Building CreateQuizScreen");
                  return const CreateQuizScreen();
                }),
              );
            },
          ),
          _buildCard(
            context,
            title: "Manage Quizzes",
            icon: Icons.manage_search,
            onTap: () {
              debugPrint("➡️ Navigating to ManageQuizzesScreen");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  debugPrint("📌 Building ManageQuizzesScreen");
                  return const ManageQuizzesScreen();
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
