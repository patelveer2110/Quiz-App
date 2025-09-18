import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // handle logout
              Navigator.pushReplacementNamed(context, '/auth');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _dashboardCard(
              context,
              title: "Join Quiz",
              icon: Icons.play_arrow,
              color: Colors.green,
              onTap: () {
                debugPrint("📌 Join Quiz tapped → navigating to /join_quiz");
                Navigator.pushNamed(context, '/join_quiz');
              },
            ),
            _dashboardCard(
              context,
              title: "Quiz History",
              icon: Icons.history,
              color: Colors.blue,
              onTap: () {
                debugPrint("📌 Quiz History tapped → navigating to /quiz_history");
                Navigator.pushNamed(context, '/quiz_history');
              },
            ),
            _dashboardCard(
              context,
              title: "Built-in Quizzes",
              icon: Icons.assignment,
              color: Colors.orange,
              onTap: () {
                debugPrint("📌 Built-in Quizzes tapped → navigating to /builtinQuizzes");
                Navigator.pushNamed(context, '/builtinQuizzes');
              },
            ),
            _dashboardCard(
              context,
              title: "Profile",
              icon: Icons.person,
              color: Colors.purple,
              onTap: () {
                debugPrint("📌 Profile tapped → navigating to /profile");
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
