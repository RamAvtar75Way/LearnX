import 'package:flutter/material.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Account Type")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoleCard(context, "Student", "I want to learn", Icons.school, "student"),
            const SizedBox(height: 16),
            _buildRoleCard(context, "Instructor", "I want to teach", Icons.person_outline, "instructor"),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String subtitle, IconData icon, String role) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterScreen(role: role)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 4),
                   Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
