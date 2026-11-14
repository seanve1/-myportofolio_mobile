// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('Profile information and action cards are displayed', (
    WidgetTester tester,
  ) async {
    // Build halaman utama dan cek identitas pemilik portfolio.
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506584161'), findsOneWidget);
    expect(find.text('Jotham Seanvedi Takin Allo'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);

    // Ketiga action card harus tersedia.
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Each action card has a different color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Warna diambil dari model ItemHomepage, bukan hardcoded di ItemCard.
    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();

    expect(cards.length, 3);
    expect(cards[0].item.color, Colors.blue);
    expect(cards[1].item.color, Colors.green);
    expect(cards[2].item.color, Colors.deepOrange);
    expect(cards.map((card) => card.item.color).toSet().length, 3);
  });

  for (final name in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
    testWidgets('SnackBar appears when $name is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Tap action card lalu cek pesan SnackBar sesuai nama tombol.
      final button = find.text(name);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    });
  }

  testWidgets('Homepage has no layout exception on 360px screen', (
    WidgetTester tester,
  ) async {
    // Simulasi viewport mobile untuk mengecek responsive layout.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Jotham Seanvedi Takin Allo'), findsOneWidget);
  });
}
