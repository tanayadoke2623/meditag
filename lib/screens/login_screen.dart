import 'home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),

                  // Logo
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'MediTag',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Color(0xFF12312E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Smart medicine identification & tracking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17201F),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Sign in to manage your pharmacy.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Email address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: const Icon(Icons.visibility_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child:  ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(
                              text: 'Create account',
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}