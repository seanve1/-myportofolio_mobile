import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/organization_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengamati apakah pengguna sudah login.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyPortfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              navigator.pop();
              navigator.pushReplacement(
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_history_outlined),
            title: const Text('View Experiences'),
            onTap: () {
              navigator.pop();
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const OrganizationListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () async {
              final allowed = await ensureLoggedIn(context);

              if (!context.mounted || !allowed) return;

              navigator.pop();

              navigator.push(
                MaterialPageRoute(builder: (_) => const ProjectFormPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_history_outlined),
            title: const Text('Add Experience'),
            onTap: () async {
              final allowed = await ensureLoggedIn(context);

              if (!context.mounted || !allowed) return;

              navigator.pop();

              navigator.push(
                MaterialPageRoute(builder: (_) => const ExperienceFormPage()),
              );
            },
          ),

          // LOGIN: ONLY FOR ANONYMOUS USERS
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                navigator.pop();

                navigator.push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),

          // LOGOUT: ONLY FOR AUTHENTICATED USERS
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final authState = context.read<AuthState>();

                // Tutup drawer terlebih dahulu.
                navigator.pop();

                try {
                  await authState.logout();

                  if (!messenger.mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Sesi login pada aplikasi telah diakhiri.'),
                    ),
                  );
                } catch (error) {
                  if (!messenger.mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sesi lokal telah diakhiri, tetapi logout server gagal.',
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
