# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Tugas 7

Pada Individual Assignment 7, saya melanjutkan pengembangan aplikasi Flutter dari Tutorial 08 dengan menyesuaikan identitas pemilik portofolio, warna pada kartu menu, serta interaksi yang tersedia pada halaman utama. Saya mengganti data contoh Burhan dengan informasi pribadi saya, yaitu nama lengkap, NPM, dan kelas PBP. Selain itu, saya juga melakukan beberapa penyesuaian pada layout agar tampilan aplikasi tetap nyaman digunakan pada ukuran layar yang berbeda.

1. **Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan parent-child bekerja antar-widget!**

   Widget tree merupakan struktur hierarki yang menggambarkan bagaimana berbagai widget disusun dan saling berhubungan di dalam aplikasi Flutter. Setiap widget dapat berperan sebagai parent yang membungkus widget lain sebagai child. Hubungan ini penting karena parent dapat menentukan susunan serta batas ruang yang tersedia bagi child-nya.

   Pada proyek saya, `MaterialApp` digunakan sebagai pembungkus aplikasi, sedangkan `MyHomePage` membangun `Scaffold` yang menyediakan `AppBar` dan bagian body. Di dalam body, terdapat `ListView`, `Wrap`, `Column`, serta `GridView.count` yang menyusun beberapa widget seperti `InfoCard` dan `ItemCard`. Dengan struktur seperti ini, saya dapat mengatur tampilan menjadi lebih terorganisir dan memisahkan komponen yang memiliki fungsi berbeda.

2. **Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!**

   Dalam proyek ini, saya menggunakan `MaterialApp` sebagai pembungkus utama aplikasi, `Scaffold` untuk menyediakan struktur halaman, dan `AppBar` untuk menampilkan judul aplikasi. Widget `Text` digunakan untuk menampilkan tulisan, sedangkan `Icon` digunakan untuk menampilkan simbol pada tombol menu.

   Untuk pengaturan layout, saya menggunakan `Padding` untuk memberikan jarak di sekitar komponen, `Center` untuk memusatkan widget, `Column` untuk menyusun komponen secara vertikal, serta `Wrap` agar kartu informasi dapat berpindah baris ketika ruang horizontal tidak mencukupi. Saya juga menggunakan `ListView` supaya halaman dapat di-scroll, `GridView.count` untuk menyusun tombol dalam bentuk grid, dan `SizedBox` untuk memberikan jarak antar-widget.

   Selain itu, `Card` dan `Container` digunakan untuk membentuk tampilan informasi profil. `Material` digunakan sebagai dasar tampilan tombol, sementara `InkWell` menangani interaksi dan memberikan ripple effect ketika tombol ditekan. `SnackBar` digunakan untuk menampilkan notifikasi melalui `ScaffoldMessenger`. Saya juga membuat dua reusable widget, yaitu `InfoCard` untuk menampilkan informasi pemilik portofolio dan `ItemCard` untuk menampilkan menu aksi.

3. **Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!**

   `MaterialApp` merupakan widget yang menyediakan konfigurasi utama bagi aplikasi berbasis Material Design, seperti tema, navigasi, dan pengaturan tampilan. Widget ini umumnya ditempatkan sebagai root widget agar komponen di bawahnya dapat menggunakan fasilitas dan konfigurasi yang telah ditentukan.

   Pada proyek saya, `MaterialApp` berada di dalam class `MyApp` pada `main.dart`. Saya menggunakan `ThemeData` dan `ColorScheme.fromSeed` untuk menentukan skema warna aplikasi. Pengaturan ini kemudian dapat diakses oleh widget lain melalui `Theme.of(context)`, seperti pada `AppBar`. Dengan begitu, pengaturan visual dasar aplikasi menjadi lebih konsisten dan terpusat.

4. **Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?**

   `StatelessWidget` merupakan widget yang tidak mengelola state lokal yang berubah selama aplikasi berjalan. Widget ini cocok digunakan untuk menampilkan data atau informasi yang relatif tetap. Sebaliknya, `StatefulWidget` digunakan ketika komponen memerlukan state yang dapat berubah, misalnya karena adanya input pengguna atau perubahan data yang perlu ditampilkan kembali melalui `setState()`.

   Pada proyek ini, saya menggunakan `StatelessWidget` pada `MyHomePage`, `InfoCard`, dan `ItemCard` karena informasi identitas serta data menu telah ditentukan sebelumnya. Ketika pengguna menekan tombol, aplikasi menampilkan `SnackBar` melalui `ScaffoldMessenger` tanpa perlu memperbarui state lokal dari `ItemCard`. Namun, jika nantinya aplikasi memiliki fitur formulir atau tampilan yang bergantung pada data yang berubah selama penggunaan, saya dapat menggunakan `StatefulWidget` atau mekanisme state management lain yang sesuai.

5. **Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?**

   `BuildContext` merupakan objek yang merepresentasikan posisi suatu widget dalam widget tree. Objek ini penting karena memungkinkan suatu widget mengakses informasi dan layanan yang tersedia dari widget lain di atasnya dalam struktur aplikasi.

   Dalam proyek saya, `BuildContext` digunakan melalui parameter `build(BuildContext context)`. Salah satu contohnya adalah `Theme.of(context)` untuk mengambil warna dari tema aplikasi. Saya juga menggunakan `MediaQuery.of(context)` untuk memperoleh ukuran layar, yang kemudian digunakan dalam menentukan lebar `InfoCard` dan jumlah kolom pada `GridView.count`. Selain itu, `ScaffoldMessenger.of(context)` digunakan untuk menampilkan `SnackBar` ketika tombol ditekan. Hal ini menunjukkan bahwa `context` membantu widget menyesuaikan perilaku dan tampilannya berdasarkan lingkungan tempat widget tersebut berada.

6. **Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?**

   *Hot reload* adalah fitur Flutter yang memungkinkan perubahan pada kode diterapkan ke aplikasi yang sedang berjalan tanpa harus memulai ulang seluruh aplikasi. Pada umumnya, hot reload mempertahankan state yang sudah ada, sehingga sangat membantu ketika melakukan perubahan tampilan seperti warna, teks, atau susunan widget.

   Sementara itu, *hot restart* menjalankan ulang aplikasi Dart dan menginisialisasi kembali state dari awal. Hot restart dapat diperlukan ketika perubahan berkaitan dengan proses inisialisasi yang tidak dieksekusi ulang melalui hot reload. Jika perubahan melibatkan konfigurasi native, dependensi platform, atau pengaturan yang membutuhkan proses build ulang, aplikasi mungkin perlu dihentikan dan dijalankan kembali secara penuh.

   Dalam pengerjaan tugas ini, hot reload membantu saya melihat perubahan pada tampilan kartu dan layout secara lebih cepat. Namun, saya juga memahami bahwa tidak semua perubahan dapat diterapkan hanya melalui hot reload, sehingga hot restart maupun full restart tetap diperlukan pada kondisi tertentu.

**AI Disclosure:**

Alat yang digunakan: ChatGPT.

Saya menggunakan bantuan ChatGPT untuk memahami beberapa konsep Flutter yang digunakan dalam pengerjaan Tugas 7, khususnya pengaturan warna pada `ItemHomepage` dan `ItemCard`, penggunaan widget untuk layout responsive, serta implementasi interaksi menggunakan `InkWell` dan `SnackBar`. Saya juga menggunakan bantuan AI untuk menyusun dan meninjau bagian kode, memahami beberapa perubahan dari Tutorial 08, serta membantu membuat skenario pengujian yang sesuai dengan kebutuhan tugas.

Dalam implementasinya, saya tetap mempertahankan struktur aplikasi dari Tutorial 08 dan membatasi perubahan pada bagian yang diperlukan. Saya menyesuaikan informasi identitas pribadi, mempertahankan menu aksi yang sudah dibuat sebelumnya, serta memeriksa kembali perubahan kode agar tidak mengubah struktur atau gaya penulisan yang masih relevan. Pengelolaan Git, termasuk staging dan commit, tetap saya lakukan secara manual.

Berikut merupakan beberapa pertanyaan atau arahan yang saya gunakan kepada AI selama pengerjaan:

1. Bagaimana cara menambahkan warna yang berbeda pada setiap `ItemCard` dengan menggunakan atribut `color` pada model `ItemHomepage`?
2. Apa fungsi `NeverScrollableScrollPhysics()` ketika `GridView.count` ditempatkan di dalam `ListView`?
3. Bagaimana cara menggunakan `MediaQuery.of(context)` untuk menyesuaikan layout dan jumlah kolom berdasarkan ukuran layar?
4. Bagaimana cara memperbaiki ripple effect melalui `InkWell` dan menyesuaikan warna `SnackBar` dengan tombol yang ditekan?
5. Bagaimana cara membuat widget tests untuk memeriksa identitas pemilik portofolio, warna tombol, interaksi `SnackBar`, dan layout pada layar mobile?

Salah satu hal yang saya pelajari dari penggunaan AI adalah bahwa saran perubahan kode tidak selalu perlu diterapkan seluruhnya. Beberapa perubahan pada awalnya terlalu banyak mengubah struktur dan gaya kode yang sudah saya gunakan dari Tutorial 08. Oleh karena itu, saya melakukan penyesuaian kembali agar implementasi tetap sesuai dengan struktur sebelumnya, sambil mempertahankan perubahan yang memang dibutuhkan untuk meningkatkan responsivitas dan interaksi aplikasi.

Selain itu, saya juga memahami bahwa hasil `flutter analyze` yang bersih belum tentu menjamin tampilan aplikasi sudah sesuai pada semua ukuran layar. Karena itu, pengujian melalui Chrome dan widget tests tetap diperlukan untuk memastikan komponen serta interaksi bekerja sesuai kebutuhan.

### Tugas 8

Pada Individual Assignment 8, saya mengembangkan halaman **Tambah Pengalaman** dengan menerapkan materi navigasi, layout, form, dan validasi Flutter. Fitur ini menggunakan referensi dari model `Organization` pada portofolio Django sebelumnya, yang awalnya bernama `Experience`. Form menyediakan posisi/jabatan dan nama organisasi sebagai data wajib, serta deskripsi, URL logo, dan tanggal sebagai informasi tambahan. Saya juga menambahkan kartu aksi berwarna ungu di homepage, opsi Add Experience pada Drawer, indikator kelengkapan input, toggle untuk pengalaman yang masih berlangsung, pemilih tanggal, dan validasi urutan tanggal. Setelah validasi berhasil, data ditampilkan melalui `AlertDialog` dan belum dikirim ke database.

**1. Jelaskan perbedaan antara `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`. Metode apa yang digunakan untuk membuka formulir dari kartu aksi? Bagaimana opsi Home pada Drawer bekerja?**

`Navigator.push()` menambahkan halaman baru di atas navigation stack sehingga halaman sebelumnya tetap ada dan dapat dibuka kembali menggunakan tombol Back. `Navigator.pushReplacement()` mengganti halaman saat ini dengan halaman tujuan, sehingga halaman yang diganti tidak lagi menjadi route tepat sebelumnya. Sementara itu, `Navigator.pop()` menutup route paling atas dan menampilkan route sebelumnya.

Pada `menu.dart`, kartu **Tambah Pengalaman** menggunakan `Navigator.push()` untuk membuka `ExperienceFormPage`. Pengguna dapat kembali ke homepage melalui tombol Back pada perangkat atau AppBar sesuai platform. Pada `left_drawer.dart`, opsi **Home** menggunakan `Navigator.pushReplacement()` menuju `MyHomePage`, termasuk saat dipilih dari Experience Form. Drawer yang sama juga memiliki Add Project dan Add Experience, sehingga navigasi konsisten tanpa perlu membuat menu terpisah untuk setiap halaman.

**2. Bagaimana `Scaffold`, `AppBar`, dan `Drawer` membantu menjaga struktur halaman? Berikan contoh konsistensi tema.**

`Scaffold` membentuk struktur halaman dengan menyediakan tempat untuk `AppBar`, `Drawer`, dan `body`. `AppBar` menampilkan judul dan kendali navigasi yang konsisten, sedangkan `Drawer` menyediakan akses ke halaman utama dan kedua formulir. Karena saya memakai reusable `LeftDrawer` pada lebih dari satu halaman, perubahan navigasi cukup dilakukan pada satu komponen.

Untuk konsistensi visual, halaman utama, Project Form, dan Experience Form menggunakan warna utama dari `Theme.of(context).colorScheme.primary` pada `AppBar` serta teks/ikon putih. Experience Form menggunakan aksen indigo pada tombol Simpan dan informasi ringkasan agar selaras dengan identitas warna portofolio.

**3. Mengapa tata letak tersebut dipilih? Apa peran widget jarak dan widget penggulir pada layar terbatas?**

Experience Form disusun secara vertikal agar pengguna dapat mengisi informasi dari atas ke bawah. `SingleChildScrollView` membolehkan formulir digulir sehingga kolom-kolom di bawah, termasuk tombol Simpan, masih dapat dijangkau pada layar kecil atau ketika keyboard tampil. `Center` dan `ConstrainedBox(maxWidth: 680)` menjaga lebar konten agar tidak terlalu melebar pada desktop, sedangkan `Padding` dan `SizedBox` membuat jarak yang konsisten antarinput.

Saya juga menggunakan `Column` agar input tersusun rapi, serta `Expanded` pada label indikator kelengkapan agar teks tidak memaksa `Row` melewati lebar layar. Penyesuaian ini relevan karena pengujian awal pada viewport 360px sempat menemukan `RenderFlex overflow`, yang kemudian ditangani sebelum pengujian diulang.

**4. Apa peran `GlobalKey<FormState>`, `validator`, dan `validate()`? Berikan contoh isian yang ditolak dan jelaskan mengapa jenis keyboard saja belum cukup.**

`GlobalKey<FormState>` memberikan akses ke state dari semua field di dalam `Form`. Ketika tombol **Simpan Experience** ditekan, kode memanggil `_formKey.currentState!.validate()`. Flutter kemudian menjalankan fungsi `validator` pada masing-masing field; jika ada validator yang mengembalikan pesan kesalahan, dialog tidak akan ditampilkan.

Contohnya, posisi/jabatan berisi tiga spasi (`"   "`) akan ditolak karena setelah `trim()` nilainya kosong. Nama organisasi juga wajib diisi dan maksimal 255 karakter. URL logo yang diisi harus berupa URL HTTP(S) yang valid. Jika toggle *masih berlangsung* dimatikan, tanggal selesai harus dipilih dan tidak boleh mendahului tanggal mulai ketika keduanya tersedia. Mengatur `keyboardType: TextInputType.url` hanya memberi saran jenis keyboard kepada pengguna, bukan mencegah input salah, apalagi input hasil paste; karena itu validasi program tetap diperlukan.

#### AI Disclosure — Tugas 8

**Alat yang digunakan:** ChatGPT.

Saya menggunakan AI untuk mendiskusikan konsep navigasi, form, dan validasi Flutter, mencocokkan field aplikasi dengan model Django yang sudah ada, serta membantu menyusun kode, pengujian widget, dan patch perbaikan. Saya memilih Experience sebagai bagian portofolio yang dikembangkan dan menggunakan proyek Tugas 7 serta Tutorial 09 sebagai dasar, sehingga fitur lama tidak dibuat ulang. Perubahan yang disarankan diterapkan ke repository lokal lalu diperiksa dengan `dart format`, `flutter analyze`, `flutter test`, dan peninjauan tampilan aplikasi.

**Ringkasan tanya-jawab pendampingan AI**  

1. **Pertanyaan:** Apa perbedaan `Navigator.push()`, `pushReplacement()`, dan `pop()` dalam aplikasi dengan Drawer?  
   **Ringkasan jawaban:** `push()` membuka route baru tanpa menghapus halaman sebelumnya; `pushReplacement()` mengganti route aktif dengan tujuan; `pop()` menutup route teratas. Dalam tugas ini, kartu homepage menggunakan `push()`, sedangkan menu Home pada Drawer memakai `pushReplacement()`.

2. **Pertanyaan:** Mengapa `GlobalKey<FormState>` dan `validate()` diperlukan walaupun input sudah memakai jenis keyboard yang sesuai?  
   **Ringkasan jawaban:** Jenis keyboard hanya memudahkan pengetikan, sedangkan `validator` memastikan data mematuhi aturan, termasuk input kosong setelah `trim()`, panjang teks, format URL, dan hubungan antar tanggal.

3. **Pertanyaan:** Bagaimana menyelaraskan Experience Form Flutter dengan portofolio Django yang sudah dikerjakan?  
   **Ringkasan jawaban:** Periksa `models.py`, `forms.py`, dan migrasi. Pada proyek ini model awal `Experience` telah berubah nama menjadi `Organization`. Field `title`, `category`, deskripsi, URL logo, dan tanggalnya menjadi acuan Flutter; tidak perlu membuat model Django baru untuk Tugas 8.

4. **Pertanyaan:** Mengapa `flutter analyze` dapat lulus tetapi widget test masih gagal akibat `RenderFlex overflow`?  
   **Ringkasan jawaban:** Analisis statis tidak menjalankan layout dalam ukuran layar tertentu. Overflow muncul ketika widget benar-benar dirender pada viewport sempit. Solusinya memperbaiki constraints atau susunan widget, lalu menjalankan tes ulang.

5. **Pertanyaan:** Mengapa tes tap kartu bisa gagal padahal kartu ditemukan oleh `find.text()`?  
   **Ringkasan jawaban:** Finder dapat menemukan widget di dalam tree meskipun koordinatnya berada di luar area layar. Tes harus melakukan scroll atau `ensureVisible` sampai target bisa menerima gesture sebelum `tap()` dijalankan.

