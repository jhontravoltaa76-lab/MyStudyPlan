import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _institusiController = TextEditingController(); // Kampus/Sekolah
  final _nomorIdController = TextEditingController(); // NIM/NISN

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _userTipe = 'mahasiswa';
  String? _errorMessage;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        final userCredential = await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );

        if (userCredential == null) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "Maaf, email atau password yang Anda masukkan salah. Mohon teliti kembali.";
          });
        }
      } else {
        final userCredential = await _authService.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          _userTipe,
          _namaController.text,
          _institusiController.text,
          _nomorIdController.text,
        );

        if (userCredential == null) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "Gagal membuat akun. Email ini mungkin sudah terdaftar.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Terjadi error: ${e.toString()}";
      });
    }
  }

  void _toggleMode() {
    if (_isLoading) return;
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.white54,
            blurRadius: 10,
            offset: Offset(-4, -4),
          ),
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? !_isPasswordVisible : false,
              keyboardType: keyboardType,
              validator: validator,
              style: GoogleFonts.outfit(
                color: const Color(0xFF004D40),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                icon: Icon(icon, color: const Color(0xFF00695C)),
                labelText: labelText,
                labelStyle: GoogleFonts.outfit(
                  color: const Color(0xFF004D40).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF00695C),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF00695C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF008080), Color(0xFFE0F7F6), Colors.white],
              ),
            ),
          ),
          // Floating Shapes
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4DB).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0083B0).withOpacity(0.15),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo (Sudah bersih dari ShaderMask luar)
                    Container(
                      width: 100,
                      height: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFF00B4DB),
                                            Color(0xFF0083B0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: const Icon(
                                      Icons.school,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isLogin ? 'Selamat Datang' : 'Buat Akun',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF004D40),
                        shadows: const [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Forms (Kondisi Registrasi Akun Baru)
                    if (!_isLogin) ...[
                      // Role Selection
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'mahasiswa',
                                  groupValue: _userTipe,
                                  activeColor: const Color(0xFF00695C),
                                  onChanged: (val) =>
                                      setState(() => _userTipe = val!),
                                ),
                                Text(
                                  'Mahasiswa',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'siswa',
                                  groupValue: _userTipe,
                                  activeColor: const Color(0xFF00695C),
                                  onChanged: (val) =>
                                      setState(() => _userTipe = val!),
                                ),
                                Text(
                                  'Siswa',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildGlassInput(
                        controller: _namaController,
                        labelText: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                      _buildGlassInput(
                        controller: _institusiController,
                        labelText: _userTipe == 'mahasiswa'
                            ? 'Nama Universitas'
                            : 'Nama Sekolah',
                        icon: Icons.account_balance_outlined,
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                      _buildGlassInput(
                        controller: _nomorIdController,
                        labelText: _userTipe == 'mahasiswa' ? 'NIM' : 'NISN',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                    ], // <-- Di sinilah kurung siku penutup yang kemarin bocor
                    // Kolom General (Muncul di Form Login maupun Registrasi)
                    _buildGlassInput(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Email diperlukan' : null,
                    ),
                    _buildGlassInput(
                      controller: _passwordController,
                      labelText: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) =>
                          value!.length < 6 ? 'Min 6 karakter' : null,
                    ),

                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => _tampilkanDialogLupaPassword(context),
                          child: Text(
                            'Lupa Password?',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF00695C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.outfit(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    _buildActionBtn(
                      _isLogin ? 'Login' : 'Registrasi',
                      _submitForm,
                    ),
                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: _toggleMode,
                      child: RichText(
                        text: TextSpan(
                          text: _isLogin
                              ? 'Belum punya akun? '
                              : 'Sudah punya akun? ',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF004D40),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? 'Daftar di sini'
                                  : 'Masuk di sini',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00695C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _tampilkanDialogLupaPassword(BuildContext context) {
  final TextEditingController emailResetController = TextEditingController();
  final AuthService authService = AuthService();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan email Anda yang terdaftar. Kami akan mengirimkan tautan untuk memperbarui password.',
              style: GoogleFonts.outfit(fontSize: 14),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailResetController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.outfit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () async {
              String email = emailResetController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email tidak boleh kosong!',
                      style: GoogleFonts.outfit(),
                    ),
                  ),
                );
                return;
              }

              String hasil = await authService.resetPassword(email);
              Navigator.pop(context);

              if (hasil == "Sukses") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email reset password telah dikirim! Cek kotak masuk Anda.',
                      style: GoogleFonts.outfit(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(hasil, style: GoogleFonts.outfit()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Kirim',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
