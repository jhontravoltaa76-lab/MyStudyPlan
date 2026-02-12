import 'package:flutter/material.dart';
import './fitur/app_models.dart';
import './services/firestore_service.dart';
import './fitur/form_kategori.dart';
import 'halaman_isi_kegiatan.dart';

class HalamanKegiatan extends StatefulWidget {
  final FirestoreService firestoreService;
  const HalamanKegiatan({Key? key, required this.firestoreService})
    : super(key: key);

  @override
  _HalamanKegiatanState createState() => _HalamanKegiatanState();
}

class _HalamanKegiatanState extends State<HalamanKegiatan> {
  void _hapusKategori(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: const Text(
          'Semua kegiatan di dalamnya akan ikut terhapus (atau tersembunyi). Yakin?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              widget.firestoreService.deleteKategori(id);
              Navigator.pop(ctx);
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
        title: const Text('Kategori Kegiatan'), // Judul sesuai permintaan
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<KategoriKegiatan>>(
        stream: widget.firestoreService.getKategoriStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Text('Belum ada kategori. Tekan (+) untuk buat Folder.'),
            );

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final kategori = snapshot.data![index];
              return InkWell(
                onTap: () {
                  // Buka isi kategori
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HalamanIsiKegiatan(
                        kategori: kategori,
                        firestoreService: widget.firestoreService,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  // Edit nama kategori
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormKategori(kategoriEdit: kategori),
                    ),
                  );
                },
                child: Card(
                  color: Colors.teal[50],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder, size: 60, color: Colors.teal),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          kategori.namaKategori,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _hapusKategori(kategori.id!),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormKategori()),
        ),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
