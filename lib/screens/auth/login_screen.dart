import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_base/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import '../../services/service_locator.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      setState(() => isLoading = false);

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(error)),
          );
        }
      } else {
        // Login Success!
        // Pop everything to let AuthWrapper show the Dashboard (at root)
        if (mounted) {
           Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // final isLoading = context.watch<AuthProvider>().isLoading; // This line is no longer needed as isLoading is now stateful

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school, 
                    size: 64, 
                    color: theme.colorScheme.primary
                  ),
                  const SizedBox(height: 32),
                  Text(
                    t.welcome,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32), // Keep this SizedBox before email field
                  TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: t.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: t.password),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Forgot Password implementation pending")));
                      },
                      child: Text(t.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 24),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(t.signIn),
                    ),
                  ),
const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(t.or, style: const TextStyle(color: Colors.grey)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.dontHaveAccount),
                      TextButton(
                        onPressed: () => getIt<Navigation>().navigateTo('/signup'),
                        child: Text(t.signUp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
