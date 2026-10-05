import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(const MissingSupabaseConfigurationApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const MediTagApp());
}

class MediTagApp extends StatelessWidget {
  const MediTagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D8A),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class MissingSupabaseConfigurationApp extends StatelessWidget {
  const MissingSupabaseConfigurationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF1FAF8),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 70,
                  color: Color(0xFF0F9D8A),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Supabase is not configured',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please start MediTag with the Supabase configuration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}