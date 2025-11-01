import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tasks');

  Stream<List<Task>> watchActiveTasks(String userId) {
    return _collection
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => Task.fromFirestore(doc.id, doc.data()))
          .where((task) => task.status != TaskStatus.completed)
          .toList();
      tasks.sort(_sortTasks);
      return tasks;
    });
  }

  Stream<List<Task>> watchRecentlyCompletedTasks(String userId, {int limit = 5}) {
    return _collection
        .where('assignedTo', isEqualTo: userId)
        .where('status', isEqualTo: TaskStatus.completed.name)
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) {
    return _collection.doc(taskId).update({
      'status': status.name,
      if (status == TaskStatus.completed)
        'completedAt': FieldValue.serverTimestamp(),
    });
  }

  int _sortTasks(Task a, Task b) {
    if (a.priority != b.priority) {
      return b.priority.compareTo(a.priority);
    }
    final dueA = a.dueDate;
    final dueB = b.dueDate;
    if (dueA == null && dueB == null) {
      return a.title.compareTo(b.title);
    }
    if (dueA == null) {
      return 1;
    }
    if (dueB == null) {
      return -1;
    }
    return dueA.compareTo(dueB);
  }
}
