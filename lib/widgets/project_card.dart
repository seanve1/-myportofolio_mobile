import 'package:flutter/material.dart';

// Model untuk data menu --> name, icon, dan color.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ItemHomepage(this.name, this.icon, this.color, {this.onTap});
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
                duration: const Duration(seconds: 2),
              ),
            );
          // Navigasi ditentukan oleh halaman pemilik kartu melalui callback.
          item.onTap?.call();
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
