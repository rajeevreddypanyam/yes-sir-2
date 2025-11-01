import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/app_user.dart';
import '../../../models/attendance_session.dart';
import '../../../models/task.dart';
import '../../../services/attendance_service.dart';
import '../../../services/task_service.dart';

class EmployeeDashboardController extends ChangeNotifier {
  EmployeeDashboardController({
    required this.user,
    required AttendanceService attendanceService,
    required TaskService taskService,
  })  : _attendanceService = attendanceService,
        _taskService = taskService {
    _activeSubscription = _attendanceService
        .watchActiveSession(user.uid)
        .listen(_handleActiveSession, onError: _handleError);
    _recentSubscription = _attendanceService
        .watchRecentSessions(user.uid)
        .listen(_handleRecentSessions, onError: _handleError);
    _taskSubscription = _taskService
        .watchActiveTasks(user.uid)
        .listen(_handleTasks, onError: _handleError);
  }

  final AppUser user;
  final AttendanceService _attendanceService;
  final TaskService _taskService;

  StreamSubscription<AttendanceSession?>? _activeSubscription;
  StreamSubscription<List<AttendanceSession>>? _recentSubscription;
  StreamSubscription<List<Task>>? _taskSubscription;

  AttendanceSession? _activeSession;
  List<AttendanceSession> _recentSessions = const [];
  List<Task> _tasks = const [];
  bool _isUpdatingAttendance = false;
  final Set<String> _updatingTaskIds = <String>{};
  String? _errorMessage;

  AttendanceSession? get activeSession => _activeSession;
  List<AttendanceSession> get recentSessions => _recentSessions;
  List<Task> get tasks => _tasks;
  bool get isUpdatingAttendance => _isUpdatingAttendance;
  String? get errorMessage => _errorMessage;

  bool get isCheckedIn => _activeSession != null;

  bool isTaskUpdating(String taskId) => _updatingTaskIds.contains(taskId);

  @override
  void dispose() {
    _activeSubscription?.cancel();
    _recentSubscription?.cancel();
    _taskSubscription?.cancel();
    super.dispose();
  }

  Future<void> toggleAttendance() async {
    if (_isUpdatingAttendance) {
      return;
    }
    _setAttendanceProcessing(true);
    try {
      final active = _activeSession;
      if (active == null) {
        await _attendanceService.startSession(
          userId: user.uid,
          organizationId: user.organizationId,
          teamId: user.teamId,
        );
      } else {
        await _attendanceService.endSession(sessionId: active.id);
      }
    } catch (error) {
      _setError('Unable to update attendance. ${error.toString()}');
    } finally {
      _setAttendanceProcessing(false);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    if (_updatingTaskIds.contains(task.id)) {
      return;
    }
    _setTaskProcessing(task.id, true);
    try {
      final newStatus =
          task.status == TaskStatus.completed ? TaskStatus.inProgress : TaskStatus.completed;
      await _taskService.updateTaskStatus(task.id, newStatus);
    } catch (error) {
      _setError('Unable to update task. ${error.toString()}');
    } finally {
      _setTaskProcessing(task.id, false);
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void _handleActiveSession(AttendanceSession? session) {
    _activeSession = session;
    notifyListeners();
  }

  void _handleRecentSessions(List<AttendanceSession> sessions) {
    _recentSessions = sessions;
    notifyListeners();
  }

  void _handleTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    _setError(error.toString());
  }

  void _setAttendanceProcessing(bool value) {
    if (_isUpdatingAttendance == value) {
      return;
    }
    _isUpdatingAttendance = value;
    notifyListeners();
  }

  void _setTaskProcessing(String taskId, bool isUpdating) {
    if (isUpdating) {
      if (_updatingTaskIds.add(taskId)) {
        notifyListeners();
      }
      return;
    }
    if (_updatingTaskIds.remove(taskId)) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
