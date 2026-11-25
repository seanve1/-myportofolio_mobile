import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/screens/organization_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506584161";
  final String nama = "Jotham Seanvedi Takin Allo";
  final String kelas = "PBP F";

  @override
  Widget build(BuildContext context) {
    // Callback menjaga ItemCard tetap fokus pada tampilan dan interaksi.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    final items = <ItemHomepage>[
      ItemHomepage(
        "Lihat Pengalaman",
        Icons.work_history,
        Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrganizationListScreen()),
          );
        },
      ),
      ItemHomepage(
        "Tambah Proyek",
        Icons.add_circle,
        Colors.green,
        onTap: () async {
          final allowed = await ensureLoggedIn(context);
          if (!context.mounted || !allowed) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProjectFormPage()),
          );
        },
      ),
      ItemHomepage(
        "Tambah Pengalaman",
        Icons.work_history,
        Colors.purple,
        onTap: () async {
          final allowed = await ensureLoggedIn(context);
          if (!context.mounted || !allowed) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExperienceFormPage()),
          );
        },
      ),
      ItemHomepage(
        isLoggedIn ? "Logout" : "Login",
        isLoggedIn ? Icons.logout : Icons.login,
        Colors.deepOrange,
        onTap: () async {
          if (!isLoggedIn) {
            await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            return;
          }

          // Jika sudah login, lakukan logout.
          final authState = context.read<AuthState>();
          try {
            await authState.logout();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sesi login telah diakhiri.')),
            );
          } catch (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sesi lokal telah diakhiri, tetapi logout server gagal.',
                ),
              ),
            );
          }
        },
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 900 ? 2 : 4;
    final cardAspectRatio = screenWidth < 600
        ? 1.2
        : screenWidth < 900
        ? 1.4
        : 1.5;

    // Scaffold menjadi kerangka utama halaman (AppBar, body, dan SnackBar).
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
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
                  // GridView menyesuaikan jumlah kolom dengan lebar layar.
                  GridView.count(
                    // Scroll utama ditangani parent ListView, jadi GridView tidak scroll sendiri.
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: crossAxisCount,
                    // 4 kartu tetap seimbang pada desktop dan dua kolom di mobile.
                    childAspectRatio: cardAspectRatio,
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
