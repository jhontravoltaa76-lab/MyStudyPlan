import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './services/auth_service.dart';
import './services/firestore_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // FUNGSI HAPUS USER
  void _hapusUser(String uid, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Pengguna', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun atas nama "$nama"?\n\nTindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text('Hapus', style: GoogleFonts.outfit(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _firestoreService.deleteUser(uid);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pengguna berhasil dihapus', style: GoogleFonts.outfit()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // FUNGSI EDIT USER
  void _editUser(Map<String, dynamic> userData) {
    final _namaController = TextEditingController(text: userData['nama']);
    String _currentRole = userData['role'] ?? 'user';
    String _selectedTipe = userData['tipe'] ?? 'mahasiswa';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Edit Pengguna', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF00695C))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _namaController,
                      style: GoogleFonts.outfit(),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: GoogleFonts.outfit(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tipe Akun:',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTipe,
                          isExpanded: true,
                          style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16),
                          items: [
                            DropdownMenuItem(value: 'mahasiswa', child: Text('Mahasiswa', style: GoogleFonts.outfit())),
                            DropdownMenuItem(value: 'siswa', child: Text('Siswa', style: GoogleFonts.outfit())),
                          ],
                          onChanged: (val) => setState(() => _selectedTipe = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('Simpan', style: GoogleFonts.outfit(color: Colors.white)),
                  onPressed: () async {
                    await _firestoreService.updateUserData(userData['uid'], {
                      'nama': _namaController.text,
                      'role': _currentRole,
                      'tipe': _selectedTipe,
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data pengguna diperbarui', style: GoogleFonts.outfit()),
                        backgroundColor: const Color(0xFF00695C),
                      ),
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

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              count,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Soft Off-White/Gray
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF008080), Color(0xFF00B4DB)], // Teal to Ocean Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
        title: Text('Admin Dashboard', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF008080)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.outfit()));
          }

          final allUsers = snapshot.data?.docs ?? [];
          final users = allUsers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['uid'] != currentUserId;
          }).toList();

          int totalMahasiswa = users.where((u) => (u.data() as Map<String, dynamic>)['tipe'] == 'mahasiswa').length;
          int totalSiswa = users.where((u) => (u.data() as Map<String, dynamic>)['tipe'] == 'siswa').length;

          return Column(
            children: [
              // Dashboard Overview Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  children: [
                    _buildStatCard('Total Users', users.length.toString(), Icons.people_alt, Colors.indigo),
                    _buildStatCard('Mahasiswa', totalMahasiswa.toString(), Icons.school, Colors.teal),
                    _buildStatCard('Siswa', totalSiswa.toString(), Icons.backpack, Colors.deepOrange),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Users List Section
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada pengguna terdaftar.',
                          style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index].data() as Map<String, dynamic>;
                          final String uid = user['uid'];
                          final isMahasiswa = user['tipe'] == 'mahasiswa';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMahasiswa ? Colors.teal.withOpacity(0.1) : Colors.deepOrange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isMahasiswa ? Icons.school : Icons.backpack,
                                  color: isMahasiswa ? Colors.teal : Colors.deepOrange,
                                ),
                              ),
                              title: Text(
                                user['nama'] ?? 'Tanpa Nama',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(user['email'] ?? '-', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: user['role'] == 'admin' ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          user['role'].toString().toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            color: user['role'] == 'admin' ? Colors.redAccent : Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          user['tipe'].toString().toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            color: Colors.blueGrey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_square, color: Colors.orange),
                                    onPressed: () => _editUser(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                    onPressed: () => _hapusUser(uid, user['nama'] ?? 'User'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
