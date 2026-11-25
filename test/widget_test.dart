// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/models/organization.dart';
import 'package:myportofolio_mobile/screens/organization_list_screen.dart';

import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';

import 'support/fake_api_client.dart';

void main() {
  testWidgets('Profile information and action cards are displayed', (
    WidgetTester tester,
  ) async {
    // Build halaman utama dan cek identitas pemilik portfolio.
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506584161'), findsOneWidget);
    expect(find.text('Jotham Seanvedi Takin Allo'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);

    // Keempat action card harus tersedia.
    expect(find.text('Lihat Pengalaman'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Tambah Pengalaman'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Each action card has a different color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Warna diambil dari model ItemHomepage, bukan hardcoded di ItemCard.
    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();

    expect(cards.length, 4);
    expect(cards[0].item.color, Colors.blue);
    expect(cards[1].item.color, Colors.green);
    expect(cards[2].item.color, Colors.purple);
    expect(cards[3].item.color, Colors.deepOrange);
    expect(cards.map((card) => card.item.color).toSet().length, 4);
  });

  testWidgets('Lihat Pengalaman navigates to Organization List', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeApiClient()));

    final button = find.text('Lihat Pengalaman');

    await tester.scrollUntilVisible(
      button,
      240,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(OrganizationListScreen), findsOneWidget);

    expect(find.text('No experiences found.'), findsOneWidget);
  });

  for (final name in ['Tambah Proyek', 'Tambah Pengalaman', 'Login']) {
    testWidgets('SnackBar appears when $name is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Tap action card lalu cek pesan SnackBar sesuai nama tombol.
      final button = find.text(name);
      // Kartu di baris kedua dapat berada di bawah viewport widget test.
      // Scroll pada ListView utama, lalu tunggu layout selesai sebelum tap.
      await tester.scrollUntilVisible(
        button,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

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

  testWidgets(
    'Anonymous user can cancel login without opening the protected form',
    (tester) async {
      await tester.pumpWidget(MyApp(apiClient: FakeApiClient()));
      await tester.scrollUntilVisible(
        find.text('Tambah Pengalaman'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.text('Login'), findsOneWidget);
    },
  );

  testWidgets(
    'Login validation, invalid credentials, and successful login/logout',
    (tester) async {
      final client = FakeApiClient();
      await tester.pumpWidget(MyApp(apiClient: client));
      await tester.scrollUntilVisible(
        find.text('Login'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'demo');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(
        find.text('Login gagal (400). Periksa username dan password.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'demo-password');
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Logout'), findsOneWidget);
      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(client.revokedToken, 'test-token');
      expect(find.text('Login'), findsOneWidget);
    },
  );

  testWidgets(
    'Public view cannot star; authenticated user can star and unstar',
    (tester) async {
      final client = FakeApiClient(
        initial: const [
          Organization(
            id: 'demo-id',
            title: 'Demo Experience',
            category: 'Demo Org',
          ),
        ],
      );
      await tester.pumpWidget(MyApp(apiClient: client));
      await tester.ensureVisible(find.text('Lihat Pengalaman'));
      await tester.tap(find.text('Lihat Pengalaman'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Demo Experience'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Star'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final loggedInClient = FakeApiClient(
        initial: const [
          Organization(
            id: 'demo-id',
            title: 'Demo Experience',
            category: 'Demo Org',
          ),
        ],
      );
      await tester.pumpWidget(
        MyApp(apiClient: loggedInClient, initialToken: 'test-token'),
      );
      await tester.ensureVisible(find.text('Lihat Pengalaman'));
      await tester.tap(find.text('Lihat Pengalaman'));
      await tester.pumpAndSettle();
      expect(loggedInClient.listToken, 'test-token');
      await tester.tap(find.text('Demo Experience'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Star'));
      await tester.tap(find.byTooltip('Star'));
      await tester.pumpAndSettle();
      expect(find.text('1 stars'), findsOneWidget);
      await tester.tap(find.byTooltip('Unstar'));
      await tester.pumpAndSettle();
      expect(find.text('0 stars'), findsOneWidget);
    },
  );
}
