import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account pending setup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'We are preparing your workspace',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Your account was created but a user profile has not been provisioned yet.'
              ' Ask your organization admin to add you to a team and assign a role.'
              ' Once the profile is ready, sign in again to continue.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: onSignOut,
              child: const Text('Return to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
