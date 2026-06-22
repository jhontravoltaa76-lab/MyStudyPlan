import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _HomePageState extends State<HomePage> {
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

  Widget _buildMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35.0, color: color),
            ),
            const SizedBox(height: 15.0),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF008080), Color(0xFF00B4DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MyStudyPlan',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: _bukaProfil,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                // Welcome Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo,',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.userData['nama'] ?? 'Pengguna',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Menu Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                      padding: const EdgeInsets.only(top: 20, bottom: 40),
                      children: [
                        _buildMenuItem(
                          Icons.calendar_month_rounded,
                          'Jadwal',
                          const Color(0xFF00695C),
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanJadwal(firestoreService: _firestoreService, labelPengajar: _labelPengajar, labelMatkul: _labelMatkul))),
                        ),
                        _buildMenuItem(
                          Icons.assignment_rounded,
                          'Tugas',
                          Colors.orange,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanTugas(firestoreService: _firestoreService, labelMatkul: _labelMatkul))),
                        ),
                        _buildMenuItem(
                          Icons.edit_document,
                          'Catatan',
                          Colors.indigo,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanCatatan(firestoreService: _firestoreService, labelMatkul: _labelMatkul))),
                        ),
                        _buildMenuItem(
                          Icons.local_activity_rounded,
                          'Kegiatan',
                          Colors.purple,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanKegiatan(firestoreService: _firestoreService))),
                        ),
                        _buildMenuItem(
                          Icons.date_range_rounded,
                          'Kalender',
                          Colors.redAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanKalender())),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN JADWAL ---
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
  final List<String> _daftarHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Jadwal ${widget.labelMatkul}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF00695C),
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.outfit(),
            tabs: _daftarHari.map((hari) => Tab(text: hari)).toList(),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: _daftarHari.map((hari) {
            return StreamBuilder<List<JadwalMatkul>>(
              stream: widget.firestoreService.getJadwalStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('Tidak ada jadwal. Tekan (+) untuk menambah.', style: GoogleFonts.outfit()));
                
                final jadwalHariIni = snapshot.data!.where((jadwal) => jadwal.hari == hari).toList();
                jadwalHariIni.sort((a, b) => _timeToMinutes(a.jamMulai).compareTo(_timeToMinutes(b.jamMulai)));
                
                if (jadwalHariIni.isEmpty) return Center(child: Text('Tidak ada jadwal untuk hari ini.', style: GoogleFonts.outfit(color: Colors.grey)));
                
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: jadwalHariIni.length,
                  itemBuilder: (context, index) {
                    final jadwal = jadwalHariIni[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.class_, color: Color(0xFF00695C)),
                        ),
                        title: Text(jadwal.mataKuliah, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 5), Text('${widget.labelPengajar}: ${jadwal.pengajar}', style: GoogleFonts.outfit(color: Colors.grey[700]))]),
                              const SizedBox(height: 4),
                              Row(children: [const Icon(Icons.room, size: 14, color: Colors.grey), const SizedBox(width: 5), Text('Ruangan: ${jadwal.ruangan}', style: GoogleFonts.outfit(color: Colors.grey[700]))]),
                              const SizedBox(height: 4),
                              Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 5), Text('${jadwal.jamMulai.format(context)} - ${jadwal.jamSelesai.format(context)}', style: GoogleFonts.outfit(color: Colors.grey[700], fontWeight: FontWeight.w600))]),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
          backgroundColor: const Color(0xFF00695C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// --- HALAMAN TUGAS ---
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai': return Colors.green;
      case 'Diproses': return Colors.amber[800]!;
      default: return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Daftar Tugas', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: StreamBuilder<List<Tugas>>(
        stream: widget.firestoreService.getTugasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('Belum ada tugas. Tekan (+) untuk menambah.', style: GoogleFonts.outfit()));

          final daftarTugas = snapshot.data!;
          daftarTugas.sort((a, b) {
            const statusOrder = {'Belum Dikerjakan': 0, 'Diproses': 1, 'Selesai': 2};
            return (statusOrder[a.status] ?? 0).compareTo(statusOrder[b.status] ?? 0);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daftarTugas.length,
            itemBuilder: (context, index) {
              final tugas = daftarTugas[index];
              final bool isSelesai = tugas.status == 'Selesai';

              return Card(
                elevation: isSelesai ? 0 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isSelesai ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                ),
                color: isSelesai ? Colors.grey[50] : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tugas.namaTugas,
                          style: GoogleFonts.outfit(
                            decoration: isSelesai ? TextDecoration.lineThrough : TextDecoration.none,
                            color: isSelesai ? Colors.grey : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(tugas.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tugas.status,
                          style: GoogleFonts.outfit(
                            color: _getStatusColor(tugas.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.subject, size: 14, color: Colors.grey), const SizedBox(width: 5), Text('${widget.labelMatkul}: ${tugas.mataKuliahTerkait}', style: GoogleFonts.outfit(color: Colors.grey[700]))]),
                        const SizedBox(height: 5),
                        Row(children: [const Icon(Icons.event_available, size: 14, color: Colors.grey), const SizedBox(width: 5), Text('Deadline: ${DateFormat('dd MMM yyyy').format(tugas.deadline)}', style: GoogleFonts.outfit(color: isSelesai ? Colors.grey : Colors.redAccent, fontWeight: FontWeight.w600))]),
                        if (tugas.detailTugas != null && tugas.detailTugas!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(tugas.detailTugas!, style: GoogleFonts.outfit(fontStyle: FontStyle.italic, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]
                      ],
                    ),
                  ),
                  onTap: () => _navigasiKeForm(tugasEdit: tugas),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigasiKeForm(),
        tooltip: 'Tambah Tugas',
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- HALAMAN CATATAN ---
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Catatan ${widget.labelMatkul}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: StreamBuilder<List<JadwalMatkul>>(
        stream: widget.firestoreService.getJadwalStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          final daftarMatkul = snapshot.data?.map((jadwal) => jadwal.mataKuliah).toSet().toList() ?? [];
          
          if (daftarMatkul.isEmpty) return Center(child: Text('Tambah ${widget.labelMatkul} di menu Jadwal dulu.', style: GoogleFonts.outfit()));
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daftarMatkul.length,
            itemBuilder: (context, index) {
              final mataKuliah = daftarMatkul[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.book, color: Colors.indigo),
                  ),
                  title: Text(mataKuliah, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HalamanDetailCatatan(mataKuliah: mataKuliah, firestoreService: widget.firestoreService)));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pilih Mata Kuliah terlebih dahulu", style: GoogleFonts.outfit())));
        },
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- HALAMAN DETAIL CATATAN ---
class HalamanDetailCatatan extends StatefulWidget {
  final String mataKuliah;
  final FirestoreService firestoreService;
  const HalamanDetailCatatan({Key? key, required this.mataKuliah, required this.firestoreService}) : super(key: key);
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

  void _hapusCatatan(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Catatan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus catatan ini?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('Hapus', style: GoogleFonts.outfit(color: Colors.white)),
            onPressed: () {
              widget.firestoreService.deleteCatatan(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Catatan berhasil dihapus', style: GoogleFonts.outfit())));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.mataKuliah, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: StreamBuilder<List<Catatan>>(
        stream: widget.firestoreService.getCatatanStream(widget.mataKuliah),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('Belum ada catatan. Tekan (+) untuk menambah.', style: GoogleFonts.outfit()));
          
          final daftarCatatan = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daftarCatatan.length,
            itemBuilder: (context, index) {
              final catatan = daftarCatatan[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => _navigasiKeForm(catatanEdit: catatan),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note, color: Colors.indigo[300]),
                            const SizedBox(width: 8),
                            Text('Catatan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.indigo)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _hapusCatatan(catatan.id),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          catatan.teksCatatan,
                          style: GoogleFonts.outfit(fontSize: 15, color: Colors.black87, height: 1.5),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
