import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';
import 'package:flutter_base/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../payments/payment_methods_screen.dart';
import '../../models/user_model.dart';
import 'edit_profile_screen.dart';
import '../learner/downloaded_lessons_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock data for now, eventually sync with Firestore via AuthService or direct stream
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              backgroundImage: (user.profileImage != null && user.profileImage!.isNotEmpty)
                  ? (user.profileImage!.startsWith('http') 
                      ? NetworkImage(user.profileImage!) 
                      : FileImage(dart_io.File(user.profileImage!))) as ImageProvider
                  : null,
              child: (user.profileImage == null || user.profileImage!.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
             const SizedBox(height: 8),
            Chip(
              label: Text(user.role.toUpperCase()),
              backgroundColor: user.role == 'instructor' ? Colors.orange[100] : Colors.blue[100],
              labelStyle: TextStyle(color: user.role == 'instructor' ? Colors.orange[800] : Colors.blue[800]),
            ),
            const SizedBox(height: 32),
            _ProfileOption(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())
                );
              },
            ),
            _ProfileOption(
              icon: Icons.payment,
              title: "Payment Methods", 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                );
              },
            ),
             _ProfileOption(
              icon: Icons.offline_pin,
              title: "My Downloads",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadedLessonsScreen()),
                );
              },
            ),
            if (user.role == 'student')
              _ProfileOption(
                icon: Icons.history,
                title: "Purchase History",
                onTap: () {},
              ),
            _ProfileOption(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: () async {
                await authService.signOut();
                // AuthWrapper will handle navigation
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileOption({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
