import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/app_user.dart';
import '../../../models/attendance_session.dart';
import '../../../models/task.dart';
import '../controller/employee_dashboard_controller.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  final AppUser user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Day'),
        actions: [
          IconButton(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Consumer<EmployeeDashboardController>(
        builder: (context, dashboard, _) {
          return RefreshIndicator(
            onRefresh: () async {
              // Streams update automatically, but the refresh indicator offers
              // a familiar gesture for users. Delay briefly to show the effect.
              await Future<void>.delayed(const Duration(milliseconds: 350));
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _GreetingSection(user: user),
                const SizedBox(height: 16),
                if (dashboard.errorMessage != null)
                  _ErrorCard(
                    message: dashboard.errorMessage!,
                    onDismissed: dashboard.clearError,
                  ),
                _AttendanceCard(controller: dashboard),
                const SizedBox(height: 24),
                _TasksSection(controller: dashboard),
                const SizedBox(height: 24),
                _RecentSessionsSection(controller: dashboard),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${user.displayName ?? user.email}',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Track attendance, knock out tasks, and stay in sync with your team.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onDismissed});

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      color: color.errorContainer,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: color.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color.onErrorContainer),
              ),
            ),
            IconButton(
              onPressed: onDismissed,
              icon: Icon(Icons.close, color: color.onErrorContainer),
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.controller});

  final EmployeeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeSession = controller.activeSession;
    final isCheckedIn = controller.isCheckedIn;

    String subtitle;
    Widget? extra;
    if (activeSession == null) {
      subtitle = 'You are currently checked out. Start your day when you arrive on site.';
    } else {
      subtitle = 'Checked in since ${_formatTime(activeSession.startTime)}.';
      final duration = DateTime.now().difference(activeSession.startTime);
      extra = Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 20),
            const SizedBox(width: 8),
            Text('Elapsed time: ${_formatDuration(duration)}'),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCheckedIn ? Icons.play_circle_fill : Icons.pause_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCheckedIn ? 'You are checked in' : 'You are checked out',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                FilledButton(
                  onPressed: controller.isUpdatingAttendance ? null : controller.toggleAttendance,
                  child: controller.isUpdatingAttendance
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isCheckedIn ? 'Check out' : 'Check in'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            if (extra != null) extra,
          ],
        ),
      ),
    );
  }
}

class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.controller});

  final EmployeeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = controller.tasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s assignments', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          _EmptyState(
            icon: Icons.fact_check_outlined,
            message: 'No active tasks right now. Enjoy the clear runway!',
          )
        else
          ...tasks.map((task) => _TaskCard(
                task: task,
                isUpdating: controller.isTaskUpdating(task.id),
                onToggle: () => controller.toggleTaskCompletion(task),
              )),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.isUpdating,
    required this.onToggle,
  });

  final Task task;
  final bool isUpdating;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: theme.textTheme.titleMedium),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(task.description!, style: theme.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(status: task.status),
                          if (task.dueDate != null)
                            Chip(
                              avatar: const Icon(Icons.calendar_today, size: 16),
                              label: Text('Due ${_formatDueDate(task.dueDate!)}'),
                            ),
                          if (task.locationName != null)
                            Chip(
                              avatar: const Icon(Icons.location_on_outlined, size: 16),
                              label: Text(task.locationName!),
                            ),
                          if (task.priority > 0)
                            Chip(
                              avatar: const Icon(Icons.flag_outlined, size: 16),
                              label: Text('Priority ${task.priority}'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: isUpdating ? null : onToggle,
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          task.status == TaskStatus.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.status == TaskStatus.completed
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color,
                        ),
                  tooltip: task.status == TaskStatus.completed
                      ? 'Mark as in progress'
                      : 'Mark as done',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    late final Color background;
    late final Color foreground;
    late final String label;
    switch (status) {
      case TaskStatus.completed:
        background = colorScheme.primaryContainer;
        foreground = colorScheme.onPrimaryContainer;
        label = 'Completed';
        break;
      case TaskStatus.inProgress:
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        label = 'In progress';
        break;
      case TaskStatus.open:
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        label = 'Not started';
        break;
    }
    return Chip(
      backgroundColor: background,
      label: Text(label, style: TextStyle(color: foreground)),
    );
  }
}

class _RecentSessionsSection extends StatelessWidget {
  const _RecentSessionsSection({required this.controller});

  final EmployeeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = controller.recentSessions
        .where((session) => !session.isActive)
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent attendance', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (history.isEmpty)
          _EmptyState(
            icon: Icons.history_toggle_off,
            message: 'No completed sessions yet. Your first shift will appear here.',
          )
        else
          ...history.map((session) => _AttendanceHistoryTile(session: session)),
      ],
    );
  }
}

class _AttendanceHistoryTile extends StatelessWidget {
  const _AttendanceHistoryTile({required this.session});

  final AttendanceSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = session.totalDuration;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.schedule_outlined),
        title: Text('${_formatTime(session.startTime)} → ${_formatTime(session.endTime ?? session.startTime)}'),
        subtitle: duration == null
            ? const Text('Awaiting checkout confirmation')
            : Text('Duration: ${_formatDuration(duration)}'),
        trailing: session.teamId != null ? Chip(label: Text(session.teamId!)) : null,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final formatter = DateFormat('MMM d • h:mm a');
  return formatter.format(dateTime);
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) {
    return '${minutes}m';
  }
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}

String _formatDueDate(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  if (due == today) {
    return 'today';
  }
  if (due == today.add(const Duration(days: 1))) {
    return 'tomorrow';
  }
  final formatter = DateFormat('MMM d');
  return formatter.format(dueDate);
}
