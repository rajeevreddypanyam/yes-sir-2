import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { open, inProgress, completed }

class Task {
  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.assignedTo,
    this.description,
    this.dueDate,
    this.locationName,
    this.priority = 0,
  });

  final String id;
  final String title;
  final TaskStatus status;
  final String assignedTo;
  final String? description;
  final DateTime? dueDate;
  final String? locationName;
  final int priority;

  bool get isCompleted => status == TaskStatus.completed;

  Task copyWith({TaskStatus? status}) {
    return Task(
      id: id,
      title: title,
      status: status ?? this.status,
      assignedTo: assignedTo,
      description: description,
      dueDate: dueDate,
      locationName: locationName,
      priority: priority,
    );
  }

  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    final String statusValue = (data['status'] as String?) ?? 'open';
    final Timestamp? due = data['dueDate'] as Timestamp?;
    return Task(
      id: id,
      title: data['title'] as String? ?? 'Untitled task',
      status: _statusFromString(statusValue),
      assignedTo: data['assignedTo'] as String? ?? '',
      description: data['description'] as String?,
      dueDate: due?.toDate(),
      locationName: data['locationName'] as String?,
      priority: (data['priority'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status.name,
      'assignedTo': assignedTo,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      if (locationName != null) 'locationName': locationName,
      'priority': priority,
    };
  }

  static TaskStatus _statusFromString(String value) {
    switch (value) {
      case 'completed':
        return TaskStatus.completed;
      case 'inProgress':
      case 'in_progress':
        return TaskStatus.inProgress;
      default:
        return TaskStatus.open;
    }
  }
}
