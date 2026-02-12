// ... (Import bagian atas tetap sama) ...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './fitur/app_models.dart';
import './services/auth_service.dart';
import './services/firestore_service.dart';
import './fitur/form_jadwal.dart';
import './fitur/form_tugas.dart';
import './fitur/form_catatan.dart';
import 'profile_screen.dart';
import './fitur/form_halaman_kalender.dart';
import 'halaman_kegiatan.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({Key? key, required this.userData}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}
// ... (Kode HomePage, HalamanJadwal TETAP SAMA seperti sebelumnya) ...
// ... (HalamanJadwal disalin di sini) ...

class _HomePageState extends State<HomePage> {
  // ... (Isi class HomePage sama persis, hanya copy-paste)
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late String _labelPengajar;
  late String _labelMatkul;

  @override
  void initState() {
    super.initState();

    String userTipe = widget.userData['tipe'] ?? 'mahasiswa';

    if (userTipe == 'mahasiswa') {
      _labelPengajar = 'Dosen';
      _labelMatkul = 'Mata Kuliah';
    } else {
      _labelPengajar = 'Guru';
      _labelMatkul = 'Mata Pelajaran';
    }
  }

  void _bukaProfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userData: widget.userData,
          authService: _authService,
          firestoreService: _firestoreService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text('MyStudyPlan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil Saya',
            onPressed: _bukaProfil,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  widget.userData['nama'] ?? 'Pengguna',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    _buildMenuItem(
                      Icons.calendar_today,
                      'Jadwal',
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HalamanJadwal(
                            firestoreService: _firestoreService,
                            labelPengajar: _labelPengajar,
                            labelMatkul: _labelMatkul,
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.assignment,
                      'Tugas',
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HalamanTugas(
                            firestoreService: _firestoreService,
                            labelMatkul: _labelMatkul,
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.note_alt,
                      'Catatan',
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HalamanCatatan(
                            firestoreService: _firestoreService,
                            labelMatkul: _labelMatkul,
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.local_activity,
                      'Kegiatan',
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HalamanKegiatan(
                            firestoreService: _firestoreService,
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.date_range,
                      'Kalender',
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HalamanKalender()),
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

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30.0,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30.0, color: color),
            ),
            const SizedBox(height: 12.0),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HalamanJadwal extends StatefulWidget {
  final FirestoreService firestoreService;
  final String labelPengajar;
  final String labelMatkul;

  const HalamanJadwal({
    Key? key,
    required this.firestoreService,
    required this.labelPengajar,
    required this.labelMatkul,
  }) : super(key: key);

  @override
  _HalamanJadwalState createState() => _HalamanJadwalState();
}

class _HalamanJadwalState extends State<HalamanJadwal> {
  final List<String> _daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];
  void _navigasiKeForm({JadwalMatkul? jadwalEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormJadwal(
          jadwalEdit: jadwalEdit,
          labelPengajar: widget.labelPengajar,
          labelMatkul: widget.labelMatkul,
        ),
      ),
    );
  }

  void _hapusJadwal(String id) {
    widget.firestoreService.deleteJadwal(id);
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _daftarHari.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Jadwal ${widget.labelMatkul}'),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            isScrollable: true,
            tabs: _daftarHari.map((hari) => Tab(text: hari)).toList(),
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: _daftarHari.map((hari) {
            return StreamBuilder<List<JadwalMatkul>>(
              stream: widget.firestoreService.getJadwalStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Center(
                    child: Text('Tidak ada jadwal. Tekan (+) untuk menambah.'),
                  );
                final jadwalHariIni = snapshot.data!
                    .where((jadwal) => jadwal.hari == hari)
                    .toList();
                jadwalHariIni.sort(
                  (a, b) => _timeToMinutes(
                    a.jamMulai,
                  ).compareTo(_timeToMinutes(b.jamMulai)),
                );
                if (jadwalHariIni.isEmpty)
                  return const Center(
                    child: Text('Tidak ada jadwal untuk hari ini.'),
                  );
                return ListView.builder(
                  itemCount: jadwalHariIni.length,
                  itemBuilder: (context, index) {
                    final jadwal = jadwalHariIni[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(
                          jadwal.mataKuliah,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.labelPengajar}: ${jadwal.pengajar}'),
                            Text('Ruangan: ${jadwal.ruangan}'),
                            Text(
                              'Waktu: ${jadwal.jamMulai.format(context)} - ${jadwal.jamSelesai.format(context)}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusJadwal(jadwal.id!),
                        ),
                        onTap: () => _navigasiKeForm(jadwalEdit: jadwal),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigasiKeForm(),
          tooltip: 'Tambah Jadwal',
          backgroundColor: Colors.teal,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// --- HALAMAN 2: TUGAS (DI-UPDATE: TANPA CHECKBOX, DENGAN STATUS TEKS) ---
class HalamanTugas extends StatefulWidget {
  final FirestoreService firestoreService;
  final String labelMatkul;

  const HalamanTugas({
    Key? key,
    required this.firestoreService,
    required this.labelMatkul,
  }) : super(key: key);

  @override
  _HalamanTugasState createState() => _HalamanTugasState();
}

class _HalamanTugasState extends State<HalamanTugas> {
  List<String> _daftarMatkulUnik = [];

  void _navigasiKeForm({Tugas? tugasEdit}) {
    widget.firestoreService.getJadwalStream().first.then((jadwalList) {
      _daftarMatkulUnik = jadwalList.map((j) => j.mataKuliah).toSet().toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormTugas(
            tugasEdit: tugasEdit,
            daftarMatkul: _daftarMatkulUnik,
            labelMatkul: widget.labelMatkul,
          ),
        ),
      );
    });
  }

  // Fungsi helper untuk warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.amber[800]!;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Tugas>>(
        stream: widget.firestoreService.getTugasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Text('Belum ada tugas. Tekan (+) untuk menambah.'),
            );

          final daftarTugas = snapshot.data!;
          // Sortir: Belum -> Diproses -> Selesai
          daftarTugas.sort((a, b) {
            const statusOrder = {
              'Belum Dikerjakan': 0,
              'Diproses': 1,
              'Selesai': 2,
            };
            return (statusOrder[a.status] ?? 0).compareTo(
              statusOrder[b.status] ?? 0,
            );
          });

          return ListView.builder(
            itemCount: daftarTugas.length,
            itemBuilder: (context, index) {
              final tugas = daftarTugas[index];
              final bool isSelesai = tugas.status == 'Selesai';

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                color: isSelesai
                    ? Colors.grey[100]
                    : Colors.white, // Sedikit gelap jika selesai
                child: ListTile(
                  // TIDAK ADA LEADING CHECKBOX
                  title: Text(
                    tugas.namaTugas,
                    style: TextStyle(
                      decoration: isSelesai
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isSelesai ? Colors.grey : Colors.black,
                      fontWeight: isSelesai
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.labelMatkul}: ${tugas.mataKuliahTerkait}'),
                      Text(
                        'Deadline: ${DateFormat('dd MMM yyyy').format(tugas.deadline)}',
                      ),

                      // Indikator Status Teks Berwarna
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(tugas.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getStatusColor(tugas.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tugas.status,
                          style: TextStyle(
                            color: _getStatusColor(tugas.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      if (tugas.detailTugas != null &&
                          tugas.detailTugas!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            tugas.detailTugas!,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  // TIDAK ADA TRAILING SAMPAH
                  onTap: () => _navigasiKeForm(
                    tugasEdit: tugas,
                  ), // Klik untuk Edit/Hapus/Ubah Status
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigasiKeForm(),
        tooltip: 'Tambah Tugas',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- HALAMAN 4: CATATAN (Tidak Berubah) ---
class HalamanCatatan extends StatefulWidget {
  final FirestoreService firestoreService;
  final String labelMatkul;

  const HalamanCatatan({
    Key? key,
    required this.firestoreService,
    required this.labelMatkul,
  }) : super(key: key);

  @override
  _HalamanCatatanState createState() => _HalamanCatatanState();
}

class _HalamanCatatanState extends State<HalamanCatatan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan ${widget.labelMatkul}'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<JadwalMatkul>>(
        stream: widget.firestoreService.getJadwalStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final daftarMatkul =
              snapshot.data
                  ?.map((jadwal) => jadwal.mataKuliah)
                  .toSet()
                  .toList() ??
              [];
          if (daftarMatkul.isEmpty)
            return Center(
              child: Text('Tambah ${widget.labelMatkul} di menu Jadwal dulu.'),
            );
          return ListView.builder(
            itemCount: daftarMatkul.length,
            itemBuilder: (context, index) {
              final mataKuliah = daftarMatkul[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.blueGrey),
                  title: Text(mataKuliah),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanDetailCatatan(
                          mataKuliah: mataKuliah,
                          firestoreService: widget.firestoreService,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pilih Mata Kuliah terlebih dahulu")),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- HALAMAN DETAIL CATATAN (DI-UPDATE: Konfirmasi Hapus) ---
class HalamanDetailCatatan extends StatefulWidget {
  final String mataKuliah;
  final FirestoreService firestoreService;
  const HalamanDetailCatatan({
    Key? key,
    required this.mataKuliah,
    required this.firestoreService,
  }) : super(key: key);
  @override
  _HalamanDetailCatatanState createState() => _HalamanDetailCatatanState();
}

class _HalamanDetailCatatanState extends State<HalamanDetailCatatan> {
  void _navigasiKeForm({Catatan? catatanEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormCatatan(
          mataKuliah: widget.mataKuliah,
          catatanEdit: catatanEdit,
        ),
      ),
    );
  }

  // --- FUNGSI HAPUS DENGAN KONFIRMASI ---
  void _hapusCatatan(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              widget.firestoreService.deleteCatatan(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan berhasil dihapus')),
              );
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
        title: Text(widget.mataKuliah),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Catatan>>(
        stream: widget.firestoreService.getCatatanStream(widget.mataKuliah),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Text('Belum ada catatan. Tekan (+) untuk menambah.'),
            );
          final daftarCatatan = snapshot.data!;
          return ListView.builder(
            itemCount: daftarCatatan.length,
            itemBuilder: (context, index) {
              final catatan = daftarCatatan[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _navigasiKeForm(catatanEdit: catatan),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          catatan.teksCatatan,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusCatatan(catatan.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigasiKeForm(),
        tooltip: 'Tambah Catatan',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
