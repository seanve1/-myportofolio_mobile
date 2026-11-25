import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/organization.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class OrganizationDetailScreen extends StatefulWidget {
  const OrganizationDetailScreen({super.key, required this.organization});

  final Organization organization;

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  late Organization organization;
  bool _isStarring = false;

  @override
  void initState() {
    super.initState();
    organization = widget.organization;
  }

  Future<void> _toggleStar() async {
    final auth = context.read<AuthState>();
    final token = auth.token;
    final id = organization.id;
    if (_isStarring || token == null || id == null) return;

    setState(() => _isStarring = true);
    try {
      final updated = await context.read<ApiClient>().toggleOrganizationStar(
        id,
        token: token,
      );
      if (!mounted) return;
      setState(() => organization = updated);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isAuthenticationFailure) {
        try {
          await auth.logout();
        } catch (_) {
          // The local session has been cleared.
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.isAuthenticationFailure
                ? 'Sesi tidak valid. Silakan login ulang.'
                : 'Gagal memperbarui star (${error.statusCode}).',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui star. Periksa koneksi.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStarring = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not specified';
    }

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Widget _buildDescription(String title, String? description) {
    if (description == null || description.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(description),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = organization.thumbnail;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Experience Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnail != null && thumbnail.trim().isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnail,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              organization.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              organization.category,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const Divider(height: 32),

            const Text(
              'Experience Period',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '${_formatDate(organization.startedAt)} - '
              '${organization.endedAt == null ? 'Present' : _formatDate(organization.endedAt)}',
            ),

            const Divider(height: 32),

            _buildDescription('Description 1', organization.desc1),
            _buildDescription('Description 2', organization.desc2),
            _buildDescription('Description 3', organization.desc3),

            const Divider(height: 24),

            Row(
              children: [
                if (isLoggedIn && organization.id != null)
                  IconButton(
                    tooltip: organization.isStarred ? 'Unstar' : 'Star',
                    onPressed: _isStarring ? null : _toggleStar,
                    icon: Icon(
                      organization.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  )
                else
                  const Icon(Icons.star_border, color: Colors.amber),
                const SizedBox(width: 8),
                Text('${organization.starCount} stars'),
              ],
            ),

            if (organization.starredByNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Starred by: ${organization.starredByNames}'),
            ],
          ],
        ),
      ),
    );
  }
}
