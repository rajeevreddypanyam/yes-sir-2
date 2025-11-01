import 'package:flutter/material.dart';

import '../../../models/app_user.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  final AppUser user;
  final VoidCallback onSignOut;

  bool get isOrgAdmin => user.role == UserRole.orgAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isOrgAdmin ? 'Organization HQ' : 'Team HQ'),
        actions: [
          IconButton(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Good day, ${user.displayName ?? user.email}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isOrgAdmin
                ? 'Oversee your entire workforce, approve requests, and configure policies.'
                : 'Monitor your team, manage attendance exceptions, and support field staff.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _DashboardTile(
                icon: Icons.people_alt_outlined,
                title: 'Users & roles',
                description:
                    'Invite employees, promote team admins, and reset credentials.',
              ),
              _DashboardTile(
                icon: Icons.groups_3_outlined,
                title: 'Teams & shifts',
                description:
                    'Define reporting lines, assign default locations, and configure shifts.',
              ),
              _DashboardTile(
                icon: Icons.location_on_outlined,
                title: 'Locations & geofences',
                description:
                    'Create client sites, manage polygon fences, and monitor live presence.',
              ),
              _DashboardTile(
                icon: Icons.insights_outlined,
                title: 'Live dashboard',
                description:
                    'Track who is checked in, review exceptions, and drill into movement.',
              ),
              _DashboardTile(
                icon: Icons.calendar_month_outlined,
                title: 'Leave & holidays',
                description:
                    'Approve leave, publish holidays, and keep teams up to date.',
              ),
              _DashboardTile(
                icon: Icons.analytics_outlined,
                title: 'Reports & exports',
                description:
                    'Export attendance summaries, delivery proof, and compliance logs.',
              ),
              _DashboardTile(
                icon: Icons.chat_outlined,
                title: 'YES SIR Assistant',
                description:
                    'Automate onboarding, respond to queries, and run quick actions.',
              ),
              _DashboardTile(
                icon: Icons.settings_outlined,
                title: 'Organization settings',
                description:
                    'Control tracking cadence, accuracy thresholds, and notification rules.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
