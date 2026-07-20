# **📚 MyStudyPlan**

**MyStudyPlan** adalah aplikasi produktivitas dan manajemen jadwal belajar yang dirancang khusus untuk membantu pelajar dan mahasiswa mengatur waktu mereka dengan lebih efisien. Dibangun menggunakan framework **Flutter**, aplikasi ini dapat berjalan dengan mulus di berbagai platform seperti Android, iOS, Web, dan Desktop.

# **Cuplikan Tampilan**

![image alt](https://github.com/jhontravoltaa76-lab/MyStudyPlan/blob/4fb6e59ada0308439482c9ea67e3d5707d079d06/public/gambar1.png)

## **✨ Fitur Utama**

* 📅 **Manajemen Jadwal:** Buat, edit, dan atur jadwal kelas, waktu belajar mandiri, serta kegiatan ekstrakurikuler dengan antarmuka yang intuitif.  
* ✅ **Pelacakan Tugas (To-Do List):** Catat Pekerjaan Rumah (PR), proyek, dan tenggat waktu (*deadline*) agar tidak ada tugas yang terlewat.  
* 📊 **Pemantauan Progres:** Lacak tingkat produktivitas dan selesaikan target belajar Anda setiap minggunya melalui dashboard statistik.  
* 🔔 **Pengingat (Reminders):** Dapatkan notifikasi *push* untuk jadwal kelas yang akan segera dimulai atau tenggat waktu tugas yang mendekat.  
* 📱 **Cross-Platform:** Akses rencana belajar Anda kapan saja dan di mana saja. Dukungan penuh untuk perangkat Mobile (Android/iOS) maupun Desktop (Windows/macOS/Linux/Web).

## **🛠️ Teknologi yang Digunakan**

* **Framework Core:** [Flutter](https://flutter.dev/)  
* **Bahasa Pemrograman Utama:** Dart (72.5%)  
* **Dukungan Native:** C++, CMake, Swift, C, HTML  
* **Manajemen Aset:** Menggunakan aset gambar lokal kustom yang dikelola secara terstruktur di dalam direktori assets/images/.

## **📂 Struktur Direktori Proyek**

Gambaran singkat dari struktur utama repositori ini:

```
MyStudyPlan/  
├── android/          \# File konfigurasi & native code untuk Android  
├── ios/              \# File konfigurasi & native code untuk iOS  
├── lib/              \# Source code utama aplikasi (File Dart)  
│   ├── main.dart     \# Entry point aplikasi  
│   └── ...           \# (Folder model, view, controller/service)  
├── web/              \# File konfigurasi untuk build ke Web  
├── windows/          \# File konfigurasi untuk build ke Windows desktop  
├── macos/            \# File konfigurasi untuk build ke macOS  
├── linux/            \# File konfigurasi untuk build ke Linux  
├── assets/images/    \# Tempat menyimpan aset gambar lokal  
├── pubspec.yaml      \# File konfigurasi utama (dependency, assets, versi)  
└── README.md         \# Dokumentasi proyek (File ini)
```

## **🚀 Memulai Proyek (Getting Started)**

Untuk menjalankan proyek ini di mesin lokal Anda, ikuti langkah-langkah di bawah ini.

### **Prasyarat**

Pastikan Anda telah menginstal beberapa perangkat lunak berikut:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versi stabil terbaru disarankan)  
* IDE seperti [Visual Studio Code](https://code.visualstudio.com/) atau [Android Studio](https://developer.android.com/studio)  
* Emulator Android/iOS atau perangkat fisik untuk *testing*.

### **1\. Kloning Repositori**

Jalankan perintah berikut di terminal Anda untuk menyalin proyek ke komputer lokal:

```
git clone https://github.com/jhontravoltaa76-lab/MyStudyPlan.git

cd MyStudyPlan
```
### **2\. Unduh Dependensi (Packages)**

Ambil semua paket (library) yang dibutuhkan oleh proyek ini sesuai dengan pubspec.yaml:
```
flutter pub get
```
### **3\. Jalankan Aplikasi**

Pastikan emulator sudah berjalan atau perangkat asli (HP) Anda sudah tersambung melalui USB debugging. Kemudian jalankan:
```
flutter run
```
*(Opsional)* Untuk mem-build ke platform tertentu, Anda bisa menambahkan flag platform. Contoh untuk web:
```
flutter run \-d chrome
```
## **📦 Build untuk Produksi**

Jika Anda ingin menghasilkan file installer (APK/IPA/EXE), gunakan perintah berikut:

* **Android (APK):** flutter build apk \--release  
* **Android (App Bundle):** flutter build appbundle \--release  
* **iOS:** flutter build ios \--release  
* **Web:** flutter build web \--release

## **🤝 Kontribusi**

Kami sangat mengapresiasi segala bentuk kontribusi, baik itu pelaporan kutu (*bugs*), ide fitur baru, maupun perbaikan kode\! Jangan ragu untuk memeriksa halaman [Issues](https://github.com/jhontravoltaa76-lab/MyStudyPlan/issues) sebelum memulai.

Langkah-langkah untuk berkontribusi:

1. Lakukan *Fork* pada repositori ini.  
2. Buat *branch* fitur Anda dari branch main (git checkout \-b feature/FiturKerenAnda).  
3. Lakukan perubahan baris kode dan *Commit* perubahan Anda (git commit \-m 'Menambahkan Fitur Keren').  
4. *Push* ke *branch* repositori *fork* Anda (git push origin feature/FiturKerenAnda).  
5. Buka **Pull Request** di repositori utama dan jelaskan perubahan yang Anda buat.

## **📚 Pelajari Flutter Lebih Lanjut**

Jika ini adalah pertama kalinya Anda menggunakan Flutter, beberapa sumber daya berikut dapat sangat membantu:

* [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)  
* [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)  
* [Dokumentasi Resmi Flutter](https://docs.flutter.dev/)
