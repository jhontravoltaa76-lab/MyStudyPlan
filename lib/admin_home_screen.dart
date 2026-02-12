import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './services/auth_service.dart';
import './services/firestore_service.dart'; // Import Firestore Service

/*
  Halaman Dashboard Admin.
  Fitur: 
  - Melihat daftar user (KECUALI DIRI SENDIRI).
  - Mengedit Tipe user (Mahasiswa/Siswa) dan Nama.
  - Menghapus user.
  - (Fitur Edit Role telah dihapus)
*/
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // --- FUNGSI HAPUS USER ---
  void _hapusUser(String uid, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun atas nama "$nama"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _firestoreService.deleteUser(uid);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengguna berhasil dihapus')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // --- FUNGSI EDIT USER (Tanpa Edit Role) ---
  void _editUser(Map<String, dynamic> userData) {
    final _namaController = TextEditingController(text: userData['nama']);
    // Role tidak diedit, kita ambil nilai lama saja untuk jaga-jaga
    String _currentRole = userData['role'] ?? 'user';
    String _selectedTipe = userData['tipe'] ?? 'mahasiswa';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Pengguna'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bagian Edit Role DIHAPUS
                    const Text(
                      'Tipe Akun:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedTipe,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'mahasiswa',
                          child: Text('Mahasiswa'),
                        ),
                        DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                      ],
                      onChanged: (val) => setState(() => _selectedTipe = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Simpan'),
                  onPressed: () async {
                    await _firestoreService.updateUserData(userData['uid'], {
                      'nama': _namaController.text,
                      'role': _currentRole, // Tetap gunakan role yang lama
                      'tipe': _selectedTipe,
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data pengguna diperbarui')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ambil data real-time dari koleksi 'users'
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada pengguna terdaftar.'));
          }

          // --- LOGIKA FILTER: Hapus diri sendiri dari daftar ---
          final currentUserId = _authService.currentUser?.uid;
          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Hanya ambil jika UID-nya BUKAN UID saya
            return data['uid'] != currentUserId;
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('Belum ada pengguna lain.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final String uid = user['uid'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    // Warna ikon berbeda untuk Mahasiswa vs Siswa
                    backgroundColor: user['tipe'] == 'mahasiswa'
                        ? Colors.teal[100]
                        : Colors.orange[100],
                    child: Icon(
                      user['tipe'] == 'mahasiswa'
                          ? Icons.school
                          : Icons.backpack,
                      color: user['tipe'] == 'mahasiswa'
                          ? Colors.teal
                          : Colors.deepOrange,
                    ),
                  ),
                  title: Text(
                    user['nama'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email'] ?? '-'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Chip Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: user['role'] == 'admin'
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user['role'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Chip Tipe
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user['tipe'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // --- ICON EDIT & HAPUS DI KANAN ---
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit (Sekarang hanya Nama & Tipe)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit User',
                        onPressed: () => _editUser(user),
                      ),
                      // Hapus
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Hapus Akun',
                        onPressed: () =>
                            _hapusUser(uid, user['nama'] ?? 'User'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
