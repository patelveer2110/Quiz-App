import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _login() async {
    debugPrint("➡️ Login button pressed");
    setState(() => _loading = true);

    var user = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (user != null) {
      debugPrint("✅ Login success for user: ${user.uid}, role: ${user.role}");

      if (!mounted) return;

      if (user.role == 'admin') {
        debugPrint("➡️ Redirecting to /admin_dashboard");
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        debugPrint("➡️ Redirecting to /user_dashboard");
        Navigator.pushReplacementNamed(context, '/user_dashboard');
      }
    } else {
      debugPrint("❌ Login failed - invalid credentials");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building LoginScreen UI...");
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: () {
                debugPrint("➡️ Navigating to /signup from LoginScreen");
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
