import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/organization.dart';
import 'package:myportofolio_mobile/screens/organization_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _organizationController = TextEditingController();
  final _description1Controller = TextEditingController();
  final _description2Controller = TextEditingController();
  final _description3Controller = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startedAtController = TextEditingController();
  final _endedAtController = TextEditingController();

  DateTime? _startedAt;
  DateTime? _endedAt;

  // ended_at == null berarti pengalaman masih berlangsung pada model Django.
  bool _isOngoing = true;
  bool _isSubmitting = false;

  int get _completedRequiredFields {
    final titleComplete = _titleController.text.trim().isNotEmpty;
    final organizationComplete = _organizationController.text.trim().isNotEmpty;
    return (titleComplete ? 1 : 0) + (organizationComplete ? 1 : 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _description1Controller.dispose();
    _description2Controller.dispose();
    _description3Controller.dispose();
    _thumbnailController.dispose();
    _startedAtController.dispose();
    _endedAtController.dispose();
    super.dispose();
  }

  String? _validateRequiredText(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label wajib diisi.';
    }
    if (text.length > 255) {
      return '$label maksimal 255 karakter.';
    }
    return null;
  }

  String? _validateThumbnail(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return null;

    if (url.length > 200) {
      return 'URL logo maksimal 200 karakter.';
    }

    final uri = Uri.tryParse(url);
    final validScheme =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority &&
        uri.host.isNotEmpty;

    if (!validScheme) {
      return 'Masukkan URL logo yang valid (http:// atau https://).';
    }
    return null;
  }

  String? _validateEndDate(String? value) {
    if (_isOngoing) return null;

    if (_endedAt == null) {
      return 'Pilih tanggal selesai atau tandai masih berlangsung.';
    }

    if (_startedAt != null && _endedAt!.isBefore(_startedAt!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
    }
    return null;
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final currentValue = isStartDate ? _startedAt : _endedAt;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      helpText: isStartDate ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      if (isStartDate) {
        _startedAt = pickedDate;
        _startedAtController.text = _formatDate(pickedDate);
      } else {
        _endedAt = pickedDate;
        _endedAtController.text = _formatDate(pickedDate);
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum ditentukan';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Pilih tanggal',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 3),
          Text(value.isEmpty ? 'Tidak diisi' : value),
        ],
      ),
    );
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _saveExperience() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    // Prevent duplicate submissions while login or POST is in progress.
    setState(() => _isSubmitting = true);
    try {
      final allowed = await ensureLoggedIn(context);
      if (!mounted || !allowed) return;

      final auth = context.read<AuthState>();
      final token = auth.token;
      if (token == null) return;

      final experience = Organization(
        title: _titleController.text.trim(),
        category: _organizationController.text.trim(),
        desc1: _optionalText(_description1Controller),
        desc2: _optionalText(_description2Controller),
        desc3: _optionalText(_description3Controller),
        thumbnail: _optionalText(_thumbnailController),
        startedAt: _startedAt?.toUtc(),
        endedAt: _isOngoing ? null : _endedAt?.toUtc(),
      );

      final saved = await context.read<ApiClient>().createOrganization(
        experience,
        token: token,
      );
      if (!mounted) return;

      final period = saved.endedAt == null
          ? '${_formatDate(saved.startedAt?.toLocal())} - Sekarang'
          : '${_formatDate(saved.startedAt?.toLocal())} - ${_formatDate(saved.endedAt?.toLocal())}';

      setState(() => _isSubmitting = false);

      // Only show a confirmation after the backend accepts the request.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.work_history_outlined, color: Colors.indigo),
              SizedBox(width: 8),
              Expanded(child: Text('Experience berhasil disimpan')),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem('Posisi', saved.title),
                  _buildSummaryItem('Organisasi', saved.category),
                  _buildSummaryItem('Periode', period),
                  _buildSummaryItem('Deskripsi 1', saved.desc1 ?? ''),
                  _buildSummaryItem('Deskripsi 2', saved.desc2 ?? ''),
                  _buildSummaryItem('Deskripsi 3', saved.desc3 ?? ''),
                  _buildSummaryItem('URL Logo', saved.thumbnail ?? ''),
                  _buildSummaryItem(
                    'Status',
                    saved.endedAt == null ? 'Sedang berlangsung' : 'Selesai',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrganizationListScreen()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isAuthenticationFailure) {
        final auth = context.read<AuthState>();
        try {
          await auth.logout();
        } catch (_) {
          // AuthState clears the local token in finally.
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi tidak valid. Silakan login ulang.'),
          ),
        );
      } else {
        final message = switch (error.statusCode) {
          403 => 'Hanya pemilik portofolio yang boleh menambahkan pengalaman.',
          400 => 'Data ditolak server. Periksa kembali isian formulir.',
          _ => 'Gagal menyimpan pengalaman (${error.statusCode}).',
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menyimpan. Periksa koneksi dan data di daftar sebelum mencoba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completedRequiredFields / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Experience'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tambahkan pengalaman organisasi atau kepanitiaan '
                      'ke dalam portofolio kamu.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Expanded membuat label membungkus ke baris
                                // berikutnya, bukan memaksa Row melebar.
                                const Expanded(
                                  child: Text(
                                    'Kelengkapan informasi wajib',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_completedRequiredFields/2',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: progress),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('experience-title'),
                      controller: _titleController,
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Posisi / Jabatan *',
                        hintText: 'Contoh: Vice Project Officer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) =>
                          _validateRequiredText(value, 'Posisi / Jabatan'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('experience-organization'),
                      controller: _organizationController,
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama Organisasi *',
                        hintText: 'Contoh: Open House Fasilkom UI 2026',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      validator: (value) =>
                          _validateRequiredText(value, 'Nama organisasi'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    _buildDateField(
                      label: 'Tanggal Mulai (opsional)',
                      controller: _startedAtController,
                      onTap: () => _pickDate(isStartDate: true),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      key: const ValueKey('experience-ongoing-switch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Saat ini masih berlangsung'),
                      subtitle: const Text(
                        'Jika aktif, tanggal selesai akan dikosongkan.',
                      ),
                      value: _isOngoing,
                      onChanged: (value) {
                        setState(() {
                          _isOngoing = value;
                          if (value) {
                            _endedAt = null;
                            _endedAtController.clear();
                          }
                        });
                      },
                    ),
                    _buildDateField(
                      label: 'Tanggal Selesai',
                      controller: _endedAtController,
                      onTap: () => _pickDate(isStartDate: false),
                      validator: _validateEndDate,
                      enabled: !_isOngoing,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deskripsi / Tanggung Jawab',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('experience-desc-1'),
                      controller: _description1Controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi 1 (opsional)',
                        hintText: 'Jelaskan tanggung jawab atau pencapaian',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('experience-desc-2'),
                      controller: _description2Controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi 2 (opsional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('experience-desc-3'),
                      controller: _description3Controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi 3 (opsional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('experience-thumbnail'),
                      controller: _thumbnailController,
                      maxLength: 200,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'URL Logo Organisasi (opsional)',
                        hintText: 'https://example.com/logo.png',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                      validator: _validateThumbnail,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _saveExperience,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSubmitting ? 'Menyimpan...' : 'Simpan Experience',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '* Wajib diisi. Data disimpan ke database Django setelah server menerima permintaan. Hanya pemilik portofolio yang dapat menambahkan pengalaman.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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
