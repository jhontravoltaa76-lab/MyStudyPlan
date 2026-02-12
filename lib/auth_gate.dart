import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Pastikan ini di-import
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'mahasiswa_screens.dart'; // Halaman utama untuk User
import 'admin_home_screen.dart'; // Halaman utama untuk Admin

/*
  Ini adalah "Gerbang" yang sudah di-upgrade.
  Sekarang menggunakan StreamBuilder untuk data user real-time.
*/
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // 1. User belum login
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        // 2. User sudah login
        // --- INI PERUBAHAN UTAMANYA ---
        // Kita ganti FutureBuilder menjadi StreamBuilder
        return StreamBuilder<DocumentSnapshot>(
          // Panggil fungsi stream baru yang kita buat
          stream: authService.getUserDataStream(authSnapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError ||
                !userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              // Jika gagal ambil data (misal dokumen terhapus), logout paksa
              authService.signOut();
              return const LoginScreen();
            }

            // Ambil data dari DocumentSnapshot
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final String role = userData['role'] ?? 'user';

            // 3. Arahkan berdasarkan Role
            if (role == 'admin') {
              return const AdminHomeScreen();
            } else {
              // 4. Arahkan ke HomePage dan kirim SEMUA data user
              // Setiap kali data di Firebase berubah, 'userData' baru akan dikirim ke HomePage
              return HomePage(userData: userData);
            }
          },
        );
        // --- AKHIR PERUBAHAN ---
      },
    );
  }
}
