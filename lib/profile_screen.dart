import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
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

  late TextEditingController _namaController;
  late TextEditingController _institusiController;
  late TextEditingController _nomorIdController;

  late String _labelInstitusi;
  late String _labelNomorId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData['nama']);
    _institusiController = TextEditingController(text: widget.userData['institusi']);
    _nomorIdController = TextEditingController(text: widget.userData['nomorId']);

    String tipe = widget.userData['tipe'] ?? 'mahasiswa';
    if (tipe == 'mahasiswa') {
      _labelInstitusi = 'Asal Universitas';
      _labelNomorId = 'NIM (Nomor Induk Mahasiswa)';
    } else {
      _labelInstitusi = 'Nama Sekolah';
      _labelNomorId = 'NISN (Nomor Induk Siswa Nasional)';
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.firestoreService.updateUserProfile(
        _namaController.text,
        _institusiController.text,
        _nomorIdController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profil berhasil diperbarui!', style: GoogleFonts.outfit()),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memperbarui profil: $e', style: GoogleFonts.outfit()),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _kirimResetPassword() async {
    final String email = widget.userData['email'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mengirim email...", style: GoogleFonts.outfit()), backgroundColor: Colors.blueAccent));
    String hasil = await widget.authService.resetPassword(email);
    if (hasil == "Sukses") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email reset password telah dikirim ke $email.', style: GoogleFonts.outfit()), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasil, style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _logout() async {
    final bool? konfirmasi = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar dari akun ini?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)), onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(child: Text('Logout', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );

    if (konfirmasi == true) {
      await widget.authService.signOut();
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.outfit(fontSize: 16, color: enabled ? Colors.black87 : Colors.grey[600]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: enabled ? const Color(0xFF00695C) : Colors.grey),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        validator: enabled ? (value) => value!.isEmpty ? 'Tidak boleh kosong' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Profil Saya', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF00695C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Color(0xFF00695C)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.userData['nama'] ?? 'Pengguna',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    widget.userData['email'] ?? 'Tidak ada email',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            // Profile Form
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Personal', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 20),
                          _buildTextField('Nama Lengkap', Icons.person_outline, _namaController),
                          _buildTextField(_labelInstitusi, Icons.account_balance_outlined, _institusiController),
                          _buildTextField(_labelNomorId, Icons.badge_outlined, _nomorIdController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpanPerubahan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00695C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Simpan Perubahan', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _kirimResetPassword,
                        icon: const Icon(Icons.lock_reset, color: Colors.orange),
                        label: Text('Reset Password', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _logout,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: Text('Logout', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
