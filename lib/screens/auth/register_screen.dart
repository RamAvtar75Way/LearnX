import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/extensions.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      String? error = await authService.registerWithEmail(_email, _password, _name, widget.role);

      setState(() => _isLoading = false);

      if (error == null) {
        // Nav handled by AuthWrapper in main.dart or pop to root
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register as ${widget.role.capitalize()}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                onSaved: (val) => _name = val!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.contains('@') ? null : 'Invalid email',
                onSaved: (val) => _email = val!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password too short' : null,
                onChanged: (val) => _password = val.trim(),
                onSaved: (val) => _password = val!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (val) {
                   if (val == null || val.isEmpty) return 'Confirm password';
                   if (val != _password) return 'Passwords do not match';
                   return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Register'),
                    ),
              TextButton(
                onPressed: () {
                   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Already have an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

