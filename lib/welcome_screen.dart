import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FCF9),
              Color(0xFFFFFFFF),
              Color(0xFFE8F9F6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ---------------- LOGO ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F9D8A),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F9D8A)
                                .withOpacity(0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Text(
                      'Medi',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF102A2A),
                        letterSpacing: -1,
                      ),
                    ),

                    const Text(
                      'Tag',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F9D8A),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'Scan • Verify • Stay Safe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF628080),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 48),

                // ---------------- WELCOME TEXT ----------------
                const Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF102A2A),
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'MediTag',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F9D8A),
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Smart medicine identification\n& verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: Color(0xFF5C7A7A),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 35),

                // ---------------- MEDICINE VISUAL ----------------
                Container(
                  width: double.infinity,
                  height: 245,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDDF8F3),
                        Color(0xFFF4FFFD),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circles
                      Positioned(
                        top: -40,
                        right: -25,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFB9EEE5)
                                .withOpacity(0.45),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -50,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFA7E5DB)
                                .withOpacity(0.35),
                          ),
                        ),
                      ),

                      // Medicine box
                      Positioned(
                        left: 55,
                        bottom: 35,
                        child: Transform.rotate(
                          angle: -0.04,
                          child: Container(
                            width: 150,
                            height: 105,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_box_rounded,
                                  color: Color(0xFF0F9D8A),
                                  size: 38,
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 65,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBDEBE4),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Container(
                                  width: 45,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F4F1),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Medicine bottle
                      Positioned(
                        right: 55,
                        bottom: 30,
                        child: Column(
                          children: [
                            Container(
                              width: 75,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F9D8A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              width: 82,
                              height: 105,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.10),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF0F9D8A),
                                  size: 42,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // QR floating card
                      Positioned(
                        top: 28,
                        left: 28,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 40,
                            color: Color(0xFF102A2A),
                          ),
                        ),
                      ),

                      // Shield
                      Positioned(
                        top: 25,
                        right: 30,
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF0F9D8A),
                            size: 34,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ---------------- FEATURES ----------------
                Row(
                  children: const [
                    Expanded(
                      child: _FeatureItem(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Scan',
                        subtitle: 'Capture',
                      ),
                    ),
                    Expanded(
                      child: _FeatureItem(
                        icon: Icons.verified_rounded,
                        title: 'Verify',
                        subtitle: 'Check',
                      ),
                    ),
                    Expanded(
                      child: _FeatureItem(
                        icon: Icons.inventory_2_rounded,
                        title: 'Manage',
                        subtitle: 'Organize',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------------- GET STARTED ----------------
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D8A),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor:
                          const Color(0xFF0F9D8A).withOpacity(0.30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- LOGIN TEXT ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF668080),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF0F9D8A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// FEATURE ITEM
// ============================================================

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFDDF6F1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F9D8A),
            size: 26,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF163333),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF719090),
          ),
        ),
      ],
    );
  }
}