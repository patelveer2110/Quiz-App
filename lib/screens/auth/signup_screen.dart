import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user'; // default role
  final _authService = AuthService();
  bool _loading = false;

  void _signup() async {
    debugPrint("📩 Signup started");
    debugPrint("➡ Name: ${_nameController.text.trim()}");
    debugPrint("➡ Email: ${_emailController.text.trim()}");
    debugPrint("➡ Role: $_role");

    setState(() => _loading = true);

    try {
      var user = await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _role,
      );

      debugPrint("✅ AuthService.signUp returned: $user");

      setState(() => _loading = false);

      if (user != null) {
        if (!mounted) return;
        debugPrint("🎯 Role detected: ${user.role}");

        if (user.role == 'admin') {
          debugPrint("🚀 Navigating to Admin Dashboard");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          debugPrint("🚀 Navigating to User Dashboard");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserDashboard()),
          );
        }
      } else {
        debugPrint("❌ Signup failed: user object is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed")),
        );
      }
    } catch (e, stack) {
      setState(() => _loading = false);
      debugPrint("🔥 Signup error: $e");
      debugPrint(stack.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: "Role"),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text("User")),
                  DropdownMenuItem(value: 'admin', child: Text("Admin")),
                ],
                onChanged: (val) {
                  debugPrint("🔄 Role changed to: $val");
                  setState(() => _role = val!);
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signup,
                      child: const Text("Sign Up"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
