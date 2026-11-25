import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/organization.dart';
import 'package:myportofolio_mobile/screens/organization_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class OrganizationListScreen extends StatefulWidget {
  const OrganizationListScreen({super.key});

  @override
  State<OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends State<OrganizationListScreen> {
  late Future<List<Organization>> _organizationsFuture;
  String? _lastToken;

  @override
  void initState() {
    super.initState();

    _lastToken = context.read<AuthState>().token;
    _organizationsFuture = context.read<ApiClient>().getOrganizations(
      token: _lastToken,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = Provider.of<AuthState>(context).token;
    if (token != _lastToken) {
      _lastToken = token;
      _organizationsFuture = context.read<ApiClient>().getOrganizations(
        token: token,
      );
    }
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getOrganizations(
      token: context.read<AuthState>().token,
    );

    setState(() {
      _organizationsFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder will display the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Experiences'),
        actions: [
          IconButton(
            tooltip: 'Refresh experiences',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Organization>>(
        future: _organizationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Failed to load experiences.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final organizations = snapshot.data ?? <Organization>[];

          if (organizations.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 400,
                    child: Center(child: Text('No experiences found.')),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: organizations.length,
              itemBuilder: (context, index) {
                final organization = organizations[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: _buildThumbnail(organization),
                    title: Text(
                      organization.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        organization.category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          organization.isStarred
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text('${organization.starCount}'),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrganizationDetailScreen(
                            organization: organization,
                          ),
                        ),
                      );
                      if (mounted) await _reload();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(Organization organization) {
    final thumbnail = organization.thumbnail;

    if (thumbnail == null || thumbnail.trim().isEmpty) {
      return const CircleAvatar(child: Icon(Icons.work_outline));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        thumbnail,
        width: 55,
        height: 55,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const CircleAvatar(child: Icon(Icons.broken_image_outlined));
        },
      ),
    );
  }
}
