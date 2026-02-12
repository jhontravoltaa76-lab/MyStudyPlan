import 'package:flutter/material.dart';
import 'app_models.dart';
import '../services/firestore_service.dart';

class FormKategori extends StatefulWidget {
  final KategoriKegiatan? kategoriEdit;

  const FormKategori({Key? key, this.kategoriEdit}) : super(key: key);

  @override
  _FormKategoriState createState() => _FormKategoriState();
}

class _FormKategoriState extends State<FormKategori> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final _namaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.kategoriEdit != null) {
      _namaController.text = widget.kategoriEdit!.namaKategori;
    }
  }

  Future<void> _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (widget.kategoriEdit == null) {
          await _firestoreService.addKategori(
            KategoriKegiatan(namaKategori: _namaController.text),
          );
        } else {
          await _firestoreService.updateKategori(
            KategoriKegiatan(
              id: widget.kategoriEdit!.id,
              userId: widget.kategoriEdit!.userId,
              namaKategori: _namaController.text,
            ),
          );
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
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
          widget.kategoriEdit == null ? 'Tambah Kategori' : 'Edit Kategori',
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori (misal: Seminar, Rapat)',
                  icon: Icon(Icons.folder),
                ),
                validator: (v) => v!.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
