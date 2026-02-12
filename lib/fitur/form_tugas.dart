import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_models.dart';
import '../services/firestore_service.dart';

class FormTugas extends StatefulWidget {
  final Tugas? tugasEdit;
  final List<String> daftarMatkul;
  final String labelMatkul;

  const FormTugas({
    Key? key,
    this.tugasEdit,
    required this.daftarMatkul,
    required this.labelMatkul,
  }) : super(key: key);

  @override
  _FormTugasState createState() => _FormTugasState();
}

class _FormTugasState extends State<FormTugas> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _namaController = TextEditingController();
  final _detailController = TextEditingController();
  String? _matkulTerpilih;
  DateTime? _deadline;

  // State untuk status (String)
  String _status = 'Belum Dikerjakan';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tugasEdit != null) {
      _namaController.text = widget.tugasEdit!.namaTugas;
      _matkulTerpilih = widget.tugasEdit!.mataKuliahTerkait;
      _deadline = widget.tugasEdit!.deadline;
      _detailController.text = widget.tugasEdit?.detailTugas ?? '';
      _status = widget.tugasEdit!.status; // Load status dari database
    }
  }

  Future<void> _pilihDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _simpanForm() async {
    if (_formKey.currentState!.validate() &&
        _matkulTerpilih != null &&
        _deadline != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.tugasEdit == null) {
          // --- CREATE ---
          final tugasBaru = Tugas(
            namaTugas: _namaController.text,
            mataKuliahTerkait: _matkulTerpilih!,
            deadline: _deadline!,
            status: _status, // Simpan status yang dipilih
            detailTugas: _detailController.text,
          );
          await _firestoreService.addTugas(tugasBaru);
        } else {
          // --- UPDATE ---
          final tugasUpdate = Tugas(
            id: widget.tugasEdit!.id,
            userId: widget.tugasEdit!.userId,
            namaTugas: _namaController.text,
            mataKuliahTerkait: _matkulTerpilih!,
            deadline: _deadline!,
            status: _status, // Simpan status yang dipilih
            detailTugas: _detailController.text,
          );
          await _firestoreService.updateTugas(tugasUpdate);
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
        }
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data wajib.')),
      );
    }
  }

  // Fungsi Hapus
  void _hapusTugas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus tugas ini secara permanen?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.tugasEdit?.id != null) {
                await _firestoreService.deleteTugas(widget.tugasEdit!.id!);
                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          widget.tugasEdit == null ? 'Tambah Tugas Baru' : 'Edit Tugas',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- 3 KOLOM STATUS ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 1. Belum Dikerjakan (Merah)
                    Column(
                      children: [
                        Checkbox(
                          value: _status == 'Belum Dikerjakan',
                          activeColor: Colors.red,
                          onChanged: (val) =>
                              setState(() => _status = 'Belum Dikerjakan'),
                        ),
                        const Text(
                          "Belum",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // 2. Diproses (Kuning)
                    Column(
                      children: [
                        Checkbox(
                          value: _status == 'Diproses',
                          activeColor: Colors.amber,
                          onChanged: (val) =>
                              setState(() => _status = 'Diproses'),
                        ),
                        const Text(
                          "Diproses",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // 3. Selesai (Hijau)
                    Column(
                      children: [
                        Checkbox(
                          value: _status == 'Selesai',
                          activeColor: Colors.green,
                          onChanged: (val) =>
                              setState(() => _status = 'Selesai'),
                        ),
                        const Text(
                          "Selesai",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- AKHIR STATUS ---
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tugas',
                  icon: Icon(Icons.assignment_outlined),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Nama tugas tidak boleh kosong'
                    : null,
              ),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '${widget.labelMatkul} Terkait',
                  icon: const Icon(Icons.class_outlined),
                ),
                value: _matkulTerpilih,
                hint: Text('Pilih ${widget.labelMatkul}'),
                items: widget.daftarMatkul.map((String matkul) {
                  return DropdownMenuItem<String>(
                    value: matkul,
                    child: Text(matkul),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _matkulTerpilih = v),
                validator: (v) => v == null && widget.daftarMatkul.isNotEmpty
                    ? 'Pilih ${widget.labelMatkul}'
                    : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _detailController,
                decoration: InputDecoration(
                  labelText: 'Detail Tugas (Opsional)',
                  hintText: 'Catatan tugas...',
                  icon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? 'Pilih Deadline'
                          : 'Deadline: ${DateFormat('dd MMMM yyyy').format(_deadline!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pilihDeadline(context),
                    child: const Text(
                      'PILIH',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),
              if (widget.tugasEdit != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _hapusTugas,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    child: const Text('Hapus Tugas'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
