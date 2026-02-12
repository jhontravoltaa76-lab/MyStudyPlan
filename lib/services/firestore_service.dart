import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../fitur/app_models.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- Helper Konversi Waktu ---
  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  TimeOfDay _stringToTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  // ==========================================
  // MODUL 1: JADWAL
  // ==========================================
  CollectionReference get _jadwalCollection => _firestore.collection('jadwal');

  Map<String, dynamic> _jadwalToMap(JadwalMatkul j, String uid) => {
    'userId': uid,
    'hari': j.hari,
    'mataKuliah': j.mataKuliah,
    'pengajar': j.pengajar,
    'ruangan': j.ruangan,
    'jamMulai': _timeOfDayToString(j.jamMulai),
    'jamSelesai': _timeOfDayToString(j.jamSelesai),
  };

  JadwalMatkul _mapToJadwal(DocumentSnapshot doc) {
    Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
    return JadwalMatkul(
      id: doc.id,
      userId: d['userId'],
      hari: d['hari'],
      mataKuliah: d['mataKuliah'],
      pengajar: d['pengajar'],
      ruangan: d['ruangan'],
      jamMulai: _stringToTimeOfDay(d['jamMulai']),
      jamSelesai: _stringToTimeOfDay(d['jamSelesai']),
    );
  }

  Future<void> addJadwal(JadwalMatkul j) async {
    if (_userId != null) await _jadwalCollection.add(_jadwalToMap(j, _userId!));
  }

  Future<void> updateJadwal(JadwalMatkul j) async {
    if (_userId != null)
      await _jadwalCollection.doc(j.id).update(_jadwalToMap(j, _userId!));
  }

  Future<void> deleteJadwal(String id) async {
    await _jadwalCollection.doc(id).delete();
  }

  Stream<List<JadwalMatkul>> getJadwalStream() {
    if (_userId == null) return Stream.value([]);
    return _jadwalCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapToJadwal(d)).toList());
  }

  // ==========================================
  // MODUL 2: TUGAS
  // ==========================================
  CollectionReference get _tugasCollection => _firestore.collection('tugas');

  Map<String, dynamic> _tugasToMap(Tugas t, String uid) => {
    'userId': uid,
    'namaTugas': t.namaTugas,
    'mataKuliahTerkait': t.mataKuliahTerkait,
    'deadline': Timestamp.fromDate(t.deadline),
    'status': t.status,
    'detailTugas': t.detailTugas,
  };

  Tugas _mapToTugas(DocumentSnapshot doc) {
    Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
    return Tugas(
      id: doc.id,
      userId: d['userId'],
      namaTugas: d['namaTugas'],
      mataKuliahTerkait: d['mataKuliahTerkait'],
      deadline: (d['deadline'] as Timestamp).toDate(),
      status: d['status'] ?? 'Belum Dikerjakan',
      detailTugas: d['detailTugas'],
    );
  }

  Future<void> addTugas(Tugas t) async {
    if (_userId != null) await _tugasCollection.add(_tugasToMap(t, _userId!));
  }

  Future<void> updateTugas(Tugas t) async {
    if (_userId != null)
      await _tugasCollection.doc(t.id).update(_tugasToMap(t, _userId!));
  }

  Future<void> deleteTugas(String id) async {
    await _tugasCollection.doc(id).delete();
  }

  Stream<List<Tugas>> getTugasStream() {
    if (_userId == null) return Stream.value([]);
    return _tugasCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapToTugas(d)).toList());
  }

  // ==========================================
  // MODUL 3: CATATAN
  // ==========================================
  CollectionReference get _catatanCollection =>
      _firestore.collection('catatan');

  Map<String, dynamic> _catatanToMap(Catatan c, String uid) => {
    'id': c.id,
    'userId': uid,
    'mataKuliah': c.mataKuliah,
    'teksCatatan': c.teksCatatan,
  };

  Catatan _mapToCatatan(DocumentSnapshot doc) {
    Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
    return Catatan(
      id: doc.id,
      userId: d['userId'],
      mataKuliah: d['mataKuliah'],
      teksCatatan: d['teksCatatan'],
    );
  }

  Future<void> addCatatan(Catatan c) async {
    if (_userId != null)
      await _catatanCollection.doc(c.id).set(_catatanToMap(c, _userId!));
  }

  Future<void> updateCatatan(Catatan c) async {
    if (_userId != null)
      await _catatanCollection.doc(c.id).update(_catatanToMap(c, _userId!));
  }

  Future<void> deleteCatatan(String id) async {
    await _catatanCollection.doc(id).delete();
  }

  Stream<List<Catatan>> getCatatanStream(String mk) {
    if (_userId == null) return Stream.value([]);
    return _catatanCollection
        .where('userId', isEqualTo: _userId)
        .where('mataKuliah', isEqualTo: mk)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapToCatatan(d)).toList());
  }

  // ==========================================
  // MODUL 4: KATEGORI KEGIATAN (FOLDER)
  // ==========================================
  CollectionReference get _kategoriCollection =>
      _firestore.collection('kategori_kegiatan');

  Map<String, dynamic> _kategoriToMap(KategoriKegiatan k, String userId) {
    return {'userId': userId, 'namaKategori': k.namaKategori};
  }

  KategoriKegiatan _mapToKategori(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KategoriKegiatan(
      id: doc.id,
      userId: data['userId'],
      namaKategori: data['namaKategori'],
    );
  }

  Future<void> addKategori(KategoriKegiatan k) async {
    if (_userId == null) return;
    await _kategoriCollection.add(_kategoriToMap(k, _userId!));
  }

  Future<void> updateKategori(KategoriKegiatan k) async {
    if (_userId == null || k.id == null) return;
    await _kategoriCollection.doc(k.id).update(_kategoriToMap(k, _userId!));
  }

  Future<void> deleteKategori(String id) async {
    await _kategoriCollection.doc(id).delete();
  }

  Stream<List<KategoriKegiatan>> getKategoriStream() {
    if (_userId == null) return Stream.value([]);
    return _kategoriCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapToKategori(d)).toList());
  }

  // ==========================================
  // MODUL 5: KEGIATAN (ISI FOLDER)
  // ==========================================
  CollectionReference get _kegiatanCollection =>
      _firestore.collection('kegiatan');

  // --- MAPPER UPDATE UNTUK MENANGANI LIST HARI ---
  Map<String, dynamic> _kegiatanToMap(Kegiatan k, String userId) {
    return {
      'userId': userId,
      'kategoriId': k.kategoriId,
      'namaKegiatan': k.namaKegiatan,
      'tempat': k.tempat,
      'tipeKegiatan': k.tipeKegiatan,
      'tanggal': k.tanggal != null ? Timestamp.fromDate(k.tanggal!) : null,
      'hariBerulang': k.hariBerulang, // <-- SIMPAN LIST HARI
      'jamMulai': _timeOfDayToString(k.jamMulai),
      'jamSelesai': _timeOfDayToString(k.jamSelesai),
    };
  }

  Kegiatan _mapToKegiatan(DocumentSnapshot doc) {
    Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
    return Kegiatan(
      id: doc.id,
      userId: d['userId'],
      kategoriId: d['kategoriId'],
      namaKegiatan: d['namaKegiatan'],
      tempat: d['tempat'],
      tipeKegiatan: d['tipeKegiatan'],
      tanggal: d['tanggal'] != null
          ? (d['tanggal'] as Timestamp).toDate()
          : null,

      // <-- AMBIL LIST HARI DENGAN AMAN
      hariBerulang: d['hariBerulang'] != null
          ? List<String>.from(d['hariBerulang'])
          : null,

      jamMulai: _stringToTimeOfDay(d['jamMulai']),
      jamSelesai: _stringToTimeOfDay(d['jamSelesai']),
    );
  }

  Future<void> addKegiatan(Kegiatan k) async {
    if (_userId == null) return;
    await _kegiatanCollection.add(_kegiatanToMap(k, _userId!));
  }

  Future<void> updateKegiatan(Kegiatan k) async {
    if (_userId == null || k.id == null) return;
    await _kegiatanCollection.doc(k.id).update(_kegiatanToMap(k, _userId!));
  }

  Future<void> deleteKegiatan(String id) async {
    await _kegiatanCollection.doc(id).delete();
  }

  Stream<List<Kegiatan>> getKegiatanByKategoriStream(String kategoriId) {
    if (_userId == null) return Stream.value([]);
    return _kegiatanCollection
        .where('userId', isEqualTo: _userId)
        .where('kategoriId', isEqualTo: kategoriId)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapToKegiatan(d)).toList());
  }

  Stream<List<Kegiatan>> getKegiatanStream() {
    if (_userId == null) return Stream.value([]);
    return _kegiatanCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapToKegiatan(d)).toList());
  }

  // ==========================================
  // MANAJEMEN USER (Profil & Admin)
  // ==========================================

  // Update Profil
  Future<void> updateUserProfile(String n, String i, String id) async {
    if (_userId != null)
      await _firestore.collection('users').doc(_userId).update({
        'nama': n,
        'institusi': i,
        'nomorId': id,
      });
  }

  // Hapus User (Fitur Admin)
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // Update User Data oleh Admin
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
