import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/app_user.dart';
import '../../admin/view/admin_dashboard_screen.dart';
import '../../employee/controller/employee_dashboard_controller.dart';
import '../../employee/view/employee_home_screen.dart';
import '../../shared/view/profile_setup_screen.dart';
import '../../shared/widgets/loading_scaffold.dart';
import '../auth_controller.dart';
import 'sign_in_screen.dart';
import '../../../services/attendance_service.dart';
import '../../../services/task_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        switch (controller.status) {
          case AuthStatus.initializing:
          case AuthStatus.loadingProfile:
            return const LoadingScaffold(message: 'Loading your workspace...');
          case AuthStatus.unauthenticated:
            return SignInScreen(controller: controller);
          case AuthStatus.needsProfile:
            return ProfileSetupScreen(onSignOut: controller.signOut);
          case AuthStatus.authenticated:
            final user = controller.currentUser!;
            if (user.role == UserRole.employee) {
              return ChangeNotifierProvider<EmployeeDashboardController>(
                create: (context) => EmployeeDashboardController(
                  user: user,
                  attendanceService: context.read<AttendanceService>(),
                  taskService: context.read<TaskService>(),
                ),
                child: EmployeeHomeScreen(
                  user: user,
                  onSignOut: controller.signOut,
                ),
              );
            }
            return AdminDashboardScreen(user: user, onSignOut: controller.signOut);
          case AuthStatus.error:
            return _ErrorScaffold(
              message: controller.errorMessage ?? 'Something went wrong',
              onRetry: () => controller.signOut(),
            );
        }
      },
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'We could not load your account',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Return to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
