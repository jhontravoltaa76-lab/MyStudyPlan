import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Dihasilkan oleh 'flutterfire configure'
import 'auth_gate.dart'; // Gerbang otentikasi kita

Future<void> main() async {
  // Pastikan Flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
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
        primarySwatch: Colors.teal, // Menggunakan tema Teal sebagai dasar
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Mulai aplikasi dari AuthGate
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
