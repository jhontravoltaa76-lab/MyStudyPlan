import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_models.dart';
import '../services/firestore_service.dart';

enum TipePelaksanaan { harian, mingguan }

class FormKegiatan extends StatefulWidget {
  final String kategoriId;
  final String namaKategori;
  final Kegiatan? kegiatanEdit;

  const FormKegiatan({
    Key? key,
    required this.kategoriId,
    required this.namaKategori,
    this.kegiatanEdit,
  }) : super(key: key);

  @override
  _FormKegiatanState createState() => _FormKegiatanState();
}

class _FormKegiatanState extends State<FormKegiatan> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _namaController = TextEditingController();
  final _tempatController = TextEditingController();

  TipePelaksanaan _tipeKegiatan = TipePelaksanaan.harian;
  DateTime? _tanggal;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;

  // State untuk hari berulang
  List<String> _hariBerulang = [];
  final List<String> _daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.kegiatanEdit != null) {
      _namaController.text = widget.kegiatanEdit!.namaKegiatan;
      _tempatController.text = widget.kegiatanEdit!.tempat;
      _tipeKegiatan = widget.kegiatanEdit!.tipeKegiatan == 'Mingguan'
          ? TipePelaksanaan.mingguan
          : TipePelaksanaan.harian;
      _tanggal = widget.kegiatanEdit!.tanggal;
      _jamMulai = widget.kegiatanEdit!.jamMulai;
      _jamSelesai = widget.kegiatanEdit!.jamSelesai;

      // Load hari berulang jika ada
      if (widget.kegiatanEdit!.hariBerulang != null) {
        _hariBerulang = List.from(widget.kegiatanEdit!.hariBerulang!);
      }
    }
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pilihJam(BuildContext context, bool isJamMulai) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isJamMulai)
          _jamMulai = picked;
        else
          _jamSelesai = picked;
      });
    }
  }

  Future<void> _simpanForm() async {
    // Validasi form dasar
    if (!_formKey.currentState!.validate()) return;

    // Validasi khusus
    if (_tipeKegiatan == TipePelaksanaan.harian && _tanggal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan pilih tanggal.')));
      return;
    }
    if (_tipeKegiatan == TipePelaksanaan.mingguan && _hariBerulang.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih minimal satu hari.')));
      return;
    }
    if (_jamMulai == null || _jamSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih jam mulai dan selesai.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String tipeString = _tipeKegiatan == TipePelaksanaan.harian
        ? 'Harian'
        : 'Mingguan';
    final DateTime? tanggalSimpan = _tipeKegiatan == TipePelaksanaan.harian
        ? _tanggal
        : null;
    // Simpan list hari hanya jika mingguan
    final List<String>? hariSimpan = _tipeKegiatan == TipePelaksanaan.mingguan
        ? _hariBerulang
        : null;

    try {
      if (widget.kegiatanEdit == null) {
        await _firestoreService.addKegiatan(
          Kegiatan(
            kategoriId: widget.kategoriId,
            namaKegiatan: _namaController.text,
            tempat: _tempatController.text,
            tipeKegiatan: tipeString,
            tanggal: tanggalSimpan,
            hariBerulang: hariSimpan, // <-- Simpan data hari
            jamMulai: _jamMulai!,
            jamSelesai: _jamSelesai!,
          ),
        );
      } else {
        await _firestoreService.updateKegiatan(
          Kegiatan(
            id: widget.kegiatanEdit!.id,
            userId: widget.kegiatanEdit!.userId,
            kategoriId: widget.kategoriId,
            namaKegiatan: _namaController.text,
            tempat: _tempatController.text,
            tipeKegiatan: tipeString,
            tanggal: tanggalSimpan,
            hariBerulang: hariSimpan, // <-- Update data hari
            jamMulai: _jamMulai!,
            jamSelesai: _jamSelesai!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          '${widget.namaKategori}: ${widget.kegiatanEdit == null ? 'Baru' : 'Edit'}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kegiatan',
                  icon: Icon(Icons.event),
                ),
                validator: (v) => v!.isEmpty ? 'Isi nama' : null,
              ),
              TextFormField(
                controller: _tempatController,
                decoration: const InputDecoration(
                  labelText: 'Tempat Pelaksanaan',
                  icon: Icon(Icons.location_on),
                ),
                validator: (v) => v!.isEmpty ? 'Isi tempat' : null,
              ),
              const SizedBox(height: 20),

              const Text(
                'Tipe Pelaksanaan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RadioListTile<TipePelaksanaan>(
                title: const Text('Sehari Saja (Harian)'),
                value: TipePelaksanaan.harian,
                groupValue: _tipeKegiatan,
                activeColor: Colors.teal,
                onChanged: (v) => setState(() => _tipeKegiatan = v!),
              ),
              RadioListTile<TipePelaksanaan>(
                title: const Text('Rutin (Mingguan)'),
                subtitle: const Text('Kegiatan berulang setiap minggu'),
                value: TipePelaksanaan.mingguan,
                groupValue: _tipeKegiatan,
                activeColor: Colors.teal,
                onChanged: (v) => setState(() => _tipeKegiatan = v!),
              ),

              // --- JIKA PILIH HARIAN (TANGGAL) ---
              if (_tipeKegiatan == TipePelaksanaan.harian)
                ListTile(
                  title: Text(
                    _tanggal == null
                        ? 'Pilih Tanggal Pelaksanaan'
                        : DateFormat('dd MMM yyyy').format(_tanggal!),
                    style: TextStyle(
                      color: _tanggal == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  trailing: Text(
                    "PILIH",
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _pilihTanggal(context),
                ),

              // --- JIKA PILIH MINGGUAN (PILIH HARI) ---
              if (_tipeKegiatan == TipePelaksanaan.mingguan)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Hari:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: _daftarHari.map((hari) {
                          final bool isSelected = _hariBerulang.contains(hari);
                          return FilterChip(
                            label: Text(hari),
                            selected: isSelected,
                            selectedColor: Colors.teal[100],
                            checkmarkColor: Colors.teal,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _hariBerulang.add(hari);
                                } else {
                                  _hariBerulang.remove(hari);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  _jamMulai == null
                      ? 'Pilih Jam Mulai'
                      : _jamMulai!.format(context),
                  style: TextStyle(
                    color: _jamMulai == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
                trailing: Text(
                  "PILIH",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _pilihJam(context, true),
              ),
              ListTile(
                title: Text(
                  _jamSelesai == null
                      ? 'Pilih Jam Selesai'
                      : _jamSelesai!.format(context),
                  style: TextStyle(
                    color: _jamSelesai == null
                        ? Colors.grey[600]
                        : Colors.black,
                  ),
                ),
                trailing: Text(
                  "PILIH",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _pilihJam(context, false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
