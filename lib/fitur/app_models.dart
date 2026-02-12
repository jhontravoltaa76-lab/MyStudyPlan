import 'package:flutter/material.dart';

// Model untuk Jadwal Mata Kuliah
class JadwalMatkul {
  String? id;
  String? userId;
  String hari;
  String mataKuliah;
  String pengajar;
  String ruangan;
  TimeOfDay jamMulai;
  TimeOfDay jamSelesai;

  JadwalMatkul({
    this.id,
    this.userId,
    required this.hari,
    required this.mataKuliah,
    required this.pengajar,
    required this.ruangan,
    required this.jamMulai,
    required this.jamSelesai,
  });
}

// Model untuk Tugas (DI-UPDATE)
class Tugas {
  String? id;
  String? userId;
  String namaTugas;
  String mataKuliahTerkait;
  DateTime deadline;
  String status; // <-- GANTI 'bool selesai' JADI INI
  String? detailTugas;

  Tugas({
    this.id,
    this.userId,
    required this.namaTugas,
    required this.mataKuliahTerkait,
    required this.deadline,
    required this.status, // 'Belum Dikerjakan', 'Diproses', 'Selesai'
    this.detailTugas,
  });
}

// Model untuk Catatan
class Catatan {
  String id;
  String? userId;
  String mataKuliah;
  String teksCatatan;

  Catatan({
    required this.id,
    this.userId,
    required this.mataKuliah,
    required this.teksCatatan,
  });
}

// Model Kategori Kegiatan
class KategoriKegiatan {
  String? id;
  String? userId;
  String namaKategori;

  KategoriKegiatan({this.id, this.userId, required this.namaKategori});
}

// Model Kegiatan
class Kegiatan {
  String? id;
  String? userId;
  String? kategoriId;
  String namaKegiatan;
  String tempat;
  String tipeKegiatan;
  DateTime? tanggal;
  List<String>? hariBerulang;
  TimeOfDay jamMulai;
  TimeOfDay jamSelesai;

  Kegiatan({
    this.id,
    this.userId,
    required this.kategoriId,
    required this.namaKegiatan,
    required this.tempat,
    required this.tipeKegiatan,
    this.tanggal,
    this.hariBerulang,
    required this.jamMulai,
    required this.jamSelesai,
  });
}

// Model Helper untuk Kalender
class EventItem {
  final String nama;
  final String tipe;
  final TimeOfDay jamMulai;
  final Color warna;

  EventItem({
    required this.nama,
    required this.tipe,
    required this.jamMulai,
    required this.warna,
  });
}
