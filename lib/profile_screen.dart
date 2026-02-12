import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

/*
  Halaman profil dengan UI yang diperbarui.
  - Latar belakang Teal di AppBar
  - Form di dalam Card (Kotak Putih)
  - Tombol dengan warna kustom
*/
class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Menerima data user
  final AuthService authService;
  final FirestoreService firestoreService;

  const ProfileScreen({
    Key? key,
    required this.userData,
    required this.authService,
    required this.firestoreService,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk field yang bisa diedit
  late TextEditingController _namaController;
  late TextEditingController _institusiController;
  late TextEditingController _nomorIdController;

  // Label dinamis
  late String _labelInstitusi;
  late String _labelNomorId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller dengan data yang ada
    _namaController = TextEditingController(text: widget.userData['nama']);
    _institusiController = TextEditingController(text: widget.userData['institusi']);
    _nomorIdController = TextEditingController(text: widget.userData['nomorId']);

    // Tentukan label dinamis
    String tipe = widget.userData['tipe'] ?? 'mahasiswa';
    if (tipe == 'mahasiswa') {
      _labelInstitusi = 'Nama Kampus';
      _labelNomorId = 'NIM (Nomor Induk Mahasiswa)';
    } else {
      _labelInstitusi = 'Nama Sekolah';
      _labelNomorId = 'NISN (Nomor Induk Siswa Nasional)';
    }
  }

  // Fungsi untuk menyimpan perubahan ke Firestore
  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      await widget.firestoreService.updateUserProfile(
        _namaController.text,
        _institusiController.text,
        _nomorIdController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // Fungsi untuk mengirim email reset password
  Future<void> _kirimResetPassword() async {
    final String email = widget.userData['email'];
    String pesan = "Mengirim email...";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.blue),
    );

    String hasil = await widget.authService.resetPassword(email);

    if (hasil == "Sukses") {
      pesan = 'Email reset password telah dikirim ke $email.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: Colors.green),
      );
    } else {
      pesan = hasil;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi untuk Logout
  Future<void> _logout() async {
    final bool? konfirmasi = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await widget.authService.signOut();
      if (mounted) Navigator.pop(context); 
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Latar Belakang Judul Berwarna Teal ---
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100], // Background abu-abu muda
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Kotak Putih yang Berisi Form ---
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field Email (Tidak bisa diedit)
                      Text(
                        'Email (Tidak bisa diubah)',
                        style: Theme.of(context).textTheme.bodySmall, 
                      ),
                      Text(
                        widget.userData['email'] ?? 'Tidak ada email',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Field Nama (Bisa diedit)
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          icon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),

                      // Field Institusi (Bisa diedit, label dinamis)
                      TextFormField(
                        controller: _institusiController,
                        decoration: InputDecoration(
                          labelText: _labelInstitusi, // "Nama Kampus" atau "Nama Sekolah"
                          icon: const Icon(Icons.school),
                        ),
                        validator: (value) => value!.isEmpty ? 'Kolom ini tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),

                      // Field Nomor ID (Bisa diedit, label dinamis)
                      TextFormField(
                        controller: _nomorIdController,
                        decoration: InputDecoration(
                          labelText: _labelNomorId, // "NIM" atau "NISN"
                          icon: const Icon(Icons.badge),
                        ),
                        validator: (value) => value!.isEmpty ? 'Kolom ini tidak boleh kosong' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ), // --- Akhir dari Kotak Putih ---

            const SizedBox(height: 24),

            // --- Tombol Simpan Perubahan (Bubble Teal) ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Warna Teal
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ),
            const SizedBox(height: 16),

            // --- Tombol Reset Password (Bubble Kuning Buram) ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirimResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[100], // Warna kuning buram/pucat
                  foregroundColor: Colors.yellow[800], // Warna teks kuning tua
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Kirim Email Reset Password'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // --- Tombol Logout (Bubble Merah) ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}