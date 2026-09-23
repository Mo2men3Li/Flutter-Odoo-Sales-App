import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/odoo_provider.dart';
import '../utiles/colors.dart';
import 'customer_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true; // <-- new

  Future<void> _login() async {
    final provider = context.read<OdooProvider>();
    final ok = await provider.login(
      userNameController.text.trim(),
      passwordController.text,
    );
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Welcome !',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          color: AppColors.primaryColor,
        ),
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userNameController,
              obscureText: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                labelText: 'Username',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_sharp
                        : Icons.visibility_rounded,
                    color: AppColors.secondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                labelText: 'Password',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (provider.authError != null)
              Text(
                provider.authError!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            provider.authLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsetsGeometry.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text('Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
