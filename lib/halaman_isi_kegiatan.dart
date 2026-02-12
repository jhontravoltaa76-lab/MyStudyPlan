import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './fitur/app_models.dart';
import './services/firestore_service.dart';
import './fitur/form_kegiatan.dart';

class HalamanIsiKegiatan extends StatelessWidget {
  final KategoriKegiatan kategori;
  final FirestoreService firestoreService;

  const HalamanIsiKegiatan({
    Key? key,
    required this.kategori,
    required this.firestoreService,
  }) : super(key: key);

  void _hapusKegiatan(BuildContext context, String id, String namaKegiatan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kegiatan "$namaKegiatan"?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              firestoreService.deleteKegiatan(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kegiatan berhasil dihapus')),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- UPDATE FUNGSI FORMAT TANGGAL ---
  String _formatTanggal(Kegiatan kegiatan) {
    if (kegiatan.tipeKegiatan == 'Mingguan') {
      // Jika ada daftar hari, gabungkan jadi string
      if (kegiatan.hariBerulang != null && kegiatan.hariBerulang!.isNotEmpty) {
        return 'Setiap ${kegiatan.hariBerulang!.join(", ")}';
      }
      return 'Setiap Minggu'; // Fallback jika list kosong
    }

    if (kegiatan.tanggal != null) {
      return DateFormat('dd MMM yyyy').format(kegiatan.tanggal!);
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kategori.namaKategori),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Kegiatan>>(
        stream: firestoreService.getKegiatanByKategoriStream(kategori.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text('Folder ini kosong.'));

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final kegiatan = data[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.event_note,
                    color: Colors.teal,
                    size: 36,
                  ),
                  title: Text(
                    kegiatan.namaKegiatan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _formatTanggal(kegiatan), // Tampilkan Hari yang dipilih
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Tempat: ${kegiatan.tempat}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Pukul: ${kegiatan.jamMulai.format(context)} - ${kegiatan.jamSelesai.format(context)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _hapusKegiatan(
                      context,
                      kegiatan.id!,
                      kegiatan.namaKegiatan,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormKegiatan(
                          kategoriId: kategori.id!,
                          namaKategori: kategori.namaKategori,
                          kegiatanEdit: kegiatan,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormKegiatan(
                kategoriId: kategori.id!,
                namaKategori: kategori.namaKategori,
              ),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
