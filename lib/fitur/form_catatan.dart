import 'package:flutter/material.dart';
import 'app_models.dart';
import 'package:mystudyplan/services/firestore_service.dart';

/*
  Formulir ini sekarang terhubung ke FirestoreService.
  Ini adalah versi teks saja (tanpa foto).
*/
class FormCatatan extends StatefulWidget {
  final String mataKuliah;
  final Catatan? catatanEdit;

  const FormCatatan({super.key, required this.mataKuliah, this.catatanEdit});

  @override
  _FormCatatanState createState() => _FormCatatanState();
}

class _FormCatatanState extends State<FormCatatan> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Controller untuk input field
  final _teksController = TextEditingController();

  bool _isLoading = false; // Untuk loading indicator

  @override
  void initState() {
    super.initState();
    // Jika ini mode Edit, isi form dengan data yang ada
    if (widget.catatanEdit != null) {
      _teksController.text = widget.catatanEdit!.teksCatatan;
    }
  }

  // Fungsi untuk menyimpan data ke Firebase
  Future<void> _simpanForm() async {
    // Validasi form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      }); // Mulai loading

      try {
        if (widget.catatanEdit == null) {
          // --- MODE TAMBAH (CREATE) ---
          final catatanBaru = Catatan(
            // Buat ID unik sederhana berdasarkan waktu
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            mataKuliah: widget.mataKuliah,
            teksCatatan: _teksController.text,
          );
          // Kirim ke Firebase
          await _firestoreService.addCatatan(catatanBaru);
        } else {
          // --- MODE EDIT (UPDATE) ---
          final catatanUpdate = Catatan(
            id: widget.catatanEdit!.id, // Sertakan ID
            userId: widget.catatanEdit!.userId, // Sertakan UserID
            mataKuliah: widget.mataKuliah,
            teksCatatan: _teksController.text,
          );
          // Kirim update ke Firebase
          await _firestoreService.updateCatatan(catatanUpdate);
        }

        // Jika berhasil, tutup halaman form
        if (mounted) Navigator.pop(context);
      } catch (e) {
        // Tampilkan error jika gagal
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
        }
      } finally {
        // Hentikan loading
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.catatanEdit == null ? 'Catatan Baru' : 'Edit Catatan',
        ),
        backgroundColor: Colors.teal, // Tema Abu-biru
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Mata Kuliah: ${widget.mataKuliah}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // "Bubble" untuk catatan
              TextFormField(
                controller: _teksController,
                decoration: InputDecoration(
                  labelText: 'Tulis catatan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 10, // Buat lebih besar untuk catatan
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
