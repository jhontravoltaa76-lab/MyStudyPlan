import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
  Ini adalah layanan otentikasi.
  Fungsi 'signUpWithEmail' telah diperbarui untuk data baru.
*/
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream status login (sedang login atau tidak)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan data user saat ini
  User? get currentUser => _auth.currentUser;

  // --- FUNGSI SIGN UP (REGISTRASI) YANG DIPERBARUI ---
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String userTipe,
    String nama,
    String institusi, // Ini adalah 'Nama Kampus' atau 'Nama Sekolah'
    String nomorId, // Ini adalah 'NIM' atau 'NISN'
  ) async {
    try {
      // 1. Buat akun di Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan data tambahan (role & tipe) di Cloud Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nama': nama, // <-- DATA BARU
        'institusi': institusi, // <-- DATA BARU
        'nomorId': nomorId, // <-- DATA BARU
        'role': 'user', // Role default adalah 'user'
        'tipe': userTipe, // 'mahasiswa' atau 'siswa'
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error SignUp: $e');
      return null;
    }
  }
  // --- AKHIR FUNGSI YANG DIPERBARUI ---

  // Fungsi Sign In (Login)
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error SignIn: $e');
      return null;
    }
  }

  // Fungsi Sign Out (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fungsi untuk mendapatkan data user (termasuk role & tipe)
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getUserData: $e');
      return null;
    }
  }
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Sukses";
    } on FirebaseAuthException catch (e) {
      // Mengembalikan pesan error yang bisa dimengerti
      if (e.code == 'user-not-found') {
        return 'Email tidak ditemukan di database.';
      } else {
        return 'Gagal mengirim email: ${e.message}';
      }
    }
  }
  Stream<DocumentSnapshot> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}