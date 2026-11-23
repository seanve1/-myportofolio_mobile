import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

void main() {
  testWidgets('Kartu Tambah Pengalaman membuka Experience Form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    // GridView ada di dalam ListView. Scroll pada ListView utama
    // sebelum mengetuk kartu yang awalnya di luar viewport 800x600.
    await tester.scrollUntilVisible(
      find.text('Tambah Pengalaman'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(find.text('Add Experience'), findsOneWidget);
  });

  testWidgets('Drawer dapat membuka Experience Form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsOneWidget);
  });

  testWidgets('Home dari Drawer kembali ke halaman utama', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Posisi dan organisasi wajib diisi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.ensureVisible(find.text('Simpan Experience'));
    await tester.tap(find.text('Simpan Experience'));
    await tester.pumpAndSettle();

    expect(find.text('Posisi / Jabatan wajib diisi.'), findsOneWidget);
    expect(find.text('Nama organisasi wajib diisi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Input valid ditampilkan pada dialog ringkasan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.enterText(
      find.byKey(const ValueKey('experience-title')),
      'Vice Project Officer',
    );
    await tester.enterText(
      find.byKey(const ValueKey('experience-organization')),
      'Open House Fasilkom UI 2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('experience-desc-1')),
      'Led end-to-end event planning and execution.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('experience-thumbnail')),
      'https://example.com/logo.png',
    );

    await tester.ensureVisible(find.text('Simpan Experience'));
    await tester.tap(find.text('Simpan Experience'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.text('Vice Project Officer')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('Open House Fasilkom UI 2026'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('Led end-to-end event planning and execution.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Sedang berlangsung')),
      findsOneWidget,
    );

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('experience-title')))
          .controller!
          .text,
      'Vice Project Officer',
    );
  });

  testWidgets('URL logo tidak valid ditolak oleh validator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.enterText(
      find.byKey(const ValueKey('experience-title')),
      'Staff',
    );
    await tester.enterText(
      find.byKey(const ValueKey('experience-organization')),
      'COMPFEST 18',
    );
    await tester.enterText(
      find.byKey(const ValueKey('experience-thumbnail')),
      'bukan-url',
    );

    await tester.ensureVisible(find.text('Simpan Experience'));
    await tester.tap(find.text('Simpan Experience'));
    await tester.pumpAndSettle();

    expect(
      find.text('Masukkan URL logo yang valid (http:// atau https://).'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Pengalaman nonaktif harus memiliki tanggal selesai', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.enterText(
      find.byKey(const ValueKey('experience-title')),
      'Staff',
    );
    await tester.enterText(
      find.byKey(const ValueKey('experience-organization')),
      'COMPFEST 18',
    );
    await tester.tap(find.byKey(const ValueKey('experience-ongoing-switch')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan Experience'));
    await tester.tap(find.text('Simpan Experience'));
    await tester.pumpAndSettle();

    expect(
      find.text('Pilih tanggal selesai atau tandai masih berlangsung.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Experience Form tidak overflow pada layar mobile 360px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Add Experience'), findsOneWidget);
  });
}
