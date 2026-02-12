import 'package:flutter/material.dart';
import 'services/auth_service.dart';

/*
  Halaman UI untuk Login dan Registrasi.
  DI-UPDATE: 
  - Ikon Icons.school diganti dengan logo kustom 'Image.asset'.
*/
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk SEMUA field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _institusiController = TextEditingController(); // Kampus/Sekolah
  final _nomorIdController = TextEditingController(); // NIM/NISN

  bool _isLogin = true; // Mode default adalah Login
  bool _isLoading = false;
  String _userTipe = 'mahasiswa'; // Default tipe saat registrasi
  String? _errorMessage;

  // Fungsi submit (logikanya sama seperti sebelumnya)
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // --- Proses Login ---
        final userCredential = await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );

        if (userCredential == null) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "Maaf, email atau password yang Anda masukkan salah. Mohon masukkan email dan password secara teliti.";
          });
        }
      } else {
        // --- Proses Registrasi ---
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
                "Gagal membuat akun. Email ini mungkin sudah terdaftar atau formatnya salah.";
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

  // Fungsi untuk beralih mode
  void _toggleMode() {
    if (_isLoading) return;
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset(); // Reset form saat ganti mode
    });
  }

  // --- Widget Builder ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text(_isLogin ? 'Login MyStudyPlan' : 'Registrasi Akun'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
          ),
        ),
      ),
    );
  }

  // --- WIDGET UNTUK TAMPILAN LOGIN ---
  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png', 
          height: 120, 
        ),
        const SizedBox(height: 24),

        // --- AKHIR PERUBAHAN ---
        Text(
          'Selamat Datang Kembali',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 24),

        Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Password minimal 6 karakter' : null,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.yellowAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _toggleMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.7),
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
            ),
            child: const Text('Belum punya akun? Registrasi di sini'),
          ),
        ),
      ],
    );
  }

  // --- WIDGET UNTUK TAMPILAN REGISTRASI ---
  Widget _buildRegisterForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 120, 
        ),
        const SizedBox(height: 24),

        Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Akun Baru',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.teal),
                ),
                const SizedBox(height: 16),
                Text(
                  'Saya seorang:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioListTile<String>(
                  title: const Text('Mahasiswa'),
                  value: 'mahasiswa',
                  groupValue: _userTipe,
                  onChanged: (value) {
                    setState(() {
                      _userTipe = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Siswa'),
                  value: 'siswa',
                  groupValue: _userTipe,
                  onChanged: (value) {
                    setState(() {
                      _userTipe = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // --- Kotak Putih 2: Data Diri ---
        Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Password minimal 6 karakter' : null,
                  obscureText: true,
                ),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _institusiController,
                  decoration: InputDecoration(
                    labelText: _userTipe == 'mahasiswa'
                        ? 'Nama Kampus'
                        : 'Nama Sekolah',
                    icon: const Icon(Icons.school),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Kolom ini tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _nomorIdController,
                  decoration: InputDecoration(
                    labelText: _userTipe == 'mahasiswa' ? 'NIM' : 'NISN',
                    icon: const Icon(Icons.badge),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Kolom ini tidak boleh kosong' : null,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.yellowAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Registrasi'),
                ),
              ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _toggleMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.7),
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
            ),
            child: const Text('Sudah punya akun? Login di sini'),
          ),
        ),
      ],
    );
  }
}
