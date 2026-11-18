import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

// Form proyek menggunakan StatefulWidget karena nilainya berubah sesuai input.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _projectName = '';
  String _description = '';
  String _category = 'Web Development';
  String _technologies = '';
  String _projectLink = '';

  final List<String> _categories = const [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  void _saveProject() {
    if (!_formKey.currentState!.validate()) return;

    // Tutorial 09: data hanya ditampilkan di dialog, belum disimpan ke DB.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Proyek: $_projectName'),
              Text('Deskripsi: $_description'),
              Text('Kategori: $_category'),
              Text('Teknologi: $_technologies'),
              Text('Tautan: $_projectLink'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _formKey.currentState?.reset();
              setState(() {
                _projectName = '';
                _description = '';
                _category = 'Web Development';
                _technologies = '';
                _projectLink = '';
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama proyek: wajib diisi.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Nama Proyek',
                          labelText: 'Nama Proyek',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _projectName = value);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama proyek tidak boleh kosong!';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Deskripsi proyek: wajib diisi.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Deskripsi Proyek',
                          labelText: 'Deskripsi Proyek',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _description = value);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi proyek tidak boleh kosong!';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Pilihan kategori dengan nilai default.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Kategori Proyek',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        initialValue: _category,
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                    ),
                    // Teknologi boleh dikosongkan sesuai contoh tutorial.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Contoh: Flutter, Django, Figma',
                          labelText: 'Teknologi yang Digunakan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _technologies = value);
                        },
                      ),
                    ),
                    // Tautan proyek bersifat opsional.
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          hintText: 'URL Proyek (opsional)',
                          labelText: 'Tautan Proyek',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _projectLink = value);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.indigo,
                            ),
                          ),
                          onPressed: _saveProject,
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
