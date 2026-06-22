import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'firebase_options.dart'; // Dihasilkan oleh 'flutterfire configure'
import 'auth_gate.dart'; // Gerbang otentikasi kita

Future<void> main() async {
  // Pastikan Flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStudyPlan',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C), // Premium Teal
          primary: const Color(0xFF008080),
          secondary: const Color(0xFF00B4DB),
          background: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Mulai aplikasi dari AuthGate
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
