import 'package:flutter/material.dart';
import 'app_models.dart';
import 'package:mystudyplan/services/firestore_service.dart';

/*
  Formulir ini sekarang terhubung ke FirestoreService.
  Labelnya (Dosen/Guru) juga dinamis.
*/
class FormJadwal extends StatefulWidget {
  final JadwalMatkul? jadwalEdit;
  final String labelPengajar;
  final String labelMatkul;

  const FormJadwal({
    super.key,
    this.jadwalEdit,
    required this.labelPengajar,
    required this.labelMatkul,
  });

  @override
  _FormJadwalState createState() => _FormJadwalState();
}

class _FormJadwalState extends State<FormJadwal> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Controller untuk input field
  final _matkulController = TextEditingController();
  final _pengajarController = TextEditingController();
  final _ruanganController = TextEditingController();

  // Variabel untuk menyimpan data waktu dan hari
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
  String? _hariTerpilih;
  final List<String> _daftarHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  bool _isLoading = false; // Untuk loading indicator

  @override
  void initState() {
    super.initState();
    // Jika ini mode Edit, isi form dengan data yang ada
    if (widget.jadwalEdit != null) {
      _hariTerpilih = widget.jadwalEdit!.hari;
      _matkulController.text = widget.jadwalEdit!.mataKuliah;
      _pengajarController.text = widget.jadwalEdit!.pengajar;
      _ruanganController.text = widget.jadwalEdit!.ruangan;
      _jamMulai = widget.jadwalEdit!.jamMulai;
      _jamSelesai = widget.jadwalEdit!.jamSelesai;
    }
  }

  // Fungsi untuk menampilkan Time Picker
  Future<void> _pilihJam(BuildContext context, bool isJamMulai) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isJamMulai
          ? (_jamMulai ?? TimeOfDay.now())
          : (_jamSelesai ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isJamMulai) {
          _jamMulai = picked;
        } else {
          _jamSelesai = picked;
        }
      });
    }
  }

  // Fungsi untuk menyimpan data ke Firebase
  Future<void> _simpanForm() async {
    // Validasi form
    if (_formKey.currentState!.validate() &&
        _jamMulai != null &&
        _jamSelesai != null &&
        _hariTerpilih != null) {
      
      setState(() { _isLoading = true; }); // Mulai loading

      try {
        if (widget.jadwalEdit == null) {
          // --- MODE TAMBAH (CREATE) ---
          final jadwalBaru = JadwalMatkul(
            hari: _hariTerpilih!,
            mataKuliah: _matkulController.text,
            pengajar: _pengajarController.text,
            ruangan: _ruanganController.text,
            jamMulai: _jamMulai!,
            jamSelesai: _jamSelesai!,
          );
          // Kirim ke Firebase
          await _firestoreService.addJadwal(jadwalBaru);
        } else {
          // --- MODE EDIT (UPDATE) ---
          final jadwalUpdate = JadwalMatkul(
            id: widget.jadwalEdit!.id, // Sertakan ID untuk update
            userId: widget.jadwalEdit!.userId, // Sertakan UserID
            hari: _hariTerpilih!,
            mataKuliah: _matkulController.text,
            pengajar: _pengajarController.text,
            ruangan: _ruanganController.text,
            jamMulai: _jamMulai!,
            jamSelesai: _jamSelesai!,
          );
          // Kirim update ke Firebase
          await _firestoreService.updateJadwal(jadwalUpdate);
        }
        
        // Jika berhasil, tutup halaman form
        if (mounted) Navigator.pop(context);

      } catch (e) {
        // Tampilkan error jika gagal
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data: $e')),
          );
        }
      } finally {
        // Hentikan loading
        if (mounted) setState(() { _isLoading = false; });
      }
    } else {
      // Tampilkan pesan error jika validasi form gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap lengkapi semua data, termasuk hari dan jam.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // Tema Teal
        title: Text(
            widget.jadwalEdit == null ? 'Tambah Jadwal Baru' : 'Edit Jadwal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Hari',
                  icon: Icon(Icons.calendar_today_outlined),
                ),
                initialValue: _hariTerpilih,
                hint: const Text('Pilih Hari'),
                items: _daftarHari.map((String hari) {
                  return DropdownMenuItem<String>(
                    value: hari,
                    child: Text(hari),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _hariTerpilih = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Hari tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _matkulController,
                decoration: InputDecoration(
                  labelText: widget.labelMatkul, // Label dinamis
                  icon: const Icon(Icons.book_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.labelMatkul} tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pengajarController,
                decoration: InputDecoration(
                  labelText: widget.labelPengajar, // Label dinamis
                  icon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.labelPengajar} tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ruanganController,
                decoration: const InputDecoration(
                  labelText: 'Ruangan',
                  icon: Icon(Icons.room_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ruangan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _jamMulai == null
                          ? 'Pilih Jam Mulai'
                          : 'Jam Mulai: ${_jamMulai!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pilihJam(context, true),
                    child: const Text('PILIH'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _jamSelesai == null
                          ? 'Pilih Jam Selesai'
                          : 'Jam Selesai: ${_jamSelesai!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pilihJam(context, false),
                    child: const Text('PILIH'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanForm, // Nonaktifkan saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ), 
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) 
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}