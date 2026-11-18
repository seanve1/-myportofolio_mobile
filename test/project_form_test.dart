import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

void main() {
  testWidgets('Add Project di drawer membuka halaman form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Tombol hijau Tambah Proyek membuka form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Nama dan deskripsi proyek harus diisi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Data yang valid tampil pada dialog konfirmasi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Proyek Demo');
    await tester.enterText(find.byType(TextFormField).at(1), 'Deskripsi Demo');
    await tester.enterText(find.byType(TextFormField).at(2), 'Flutter');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'https://example.com',
    );

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Nama Proyek: Proyek Demo'), findsOneWidget);
    expect(find.text('Deskripsi: Deskripsi Demo'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter'), findsOneWidget);
    expect(find.text('Tautan: https://example.com'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
  });
}
