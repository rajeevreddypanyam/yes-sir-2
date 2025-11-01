import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/view/auth_gate.dart';
import 'services/attendance_service.dart';
import 'services/auth_repository.dart';
import 'services/firebase_auth_repository.dart';
import 'services/task_service.dart';
import 'services/user_service.dart';
import 'theme/app_theme.dart';

class YesSirApp extends StatelessWidget {
  const YesSirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),
        ),
        Provider<AttendanceService>(
          create: (_) => AttendanceService(),
        ),
        Provider<UserService>(
          create: (_) => UserService(),
        ),
        Provider<TaskService>(
          create: (_) => TaskService(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            context.read<AuthRepository>(),
            context.read<UserService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'YES SIR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const AuthGate(),
      ),
    );
  }
}
