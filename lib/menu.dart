import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506584161";
  final String nama = "Jotham Seanvedi Takin Allo";
  final String kelas = "PBP F";

  // List menu action; masing-masing item punya label, icon, dan color sendiri.
  final List<ItemHomepage> items = const [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue),
    ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green),
    ItemHomepage("Logout", Icons.logout, Colors.deepOrange),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menjadi kerangka utama halaman (AppBar, body, dan SnackBar).
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // ListView supaya content tetap bisa discroll saat viewport pendek.
        child: ListView(
          children: [
            // Wrap mengatur InfoCard. Card otomatis pindah baris kalau width tidak cukup.
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  // GridView untuk menu action. 2 kolom di mobile, 3 kolom di layar lebar.
                  GridView.count(
                    // Scroll utama ditangani parent ListView, jadi GridView tidak scroll sendiri.
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                    // Aspect ratio card disesuaikan supaya icon dan label tetap muat.
                    childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.2 : 1.6,
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Responsive width. Full-width di mobile, proporsional di layar lebar.
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width - 64
            : MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Column menyusun title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// Model untuk data menu --> name, icon, dan color.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Background color diambil dari item.color agar tiap action berbeda.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      // InkWell menangani onTap sekaligus ripple effect pada card.
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white24,
        // Saat ditap, tampilkan SnackBar dengan pesan dan warna sesuai item.
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!"),
                backgroundColor: item.color,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2)
              ),
            );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
