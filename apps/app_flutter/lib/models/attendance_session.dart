import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSession {
  AttendanceSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.organizationId,
    this.teamId,
    this.startLocation,
    this.endLocation,
  });

  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? organizationId;
  final String? teamId;
  final GeoPoint? startLocation;
  final GeoPoint? endLocation;

  bool get isActive => endTime == null;

  Duration? get totalDuration {
    final end = endTime;
    if (end == null) {
      return null;
    }
    return end.difference(startTime);
  }

  AttendanceSession copyWith({
    DateTime? endTime,
    GeoPoint? endLocation,
  }) {
    return AttendanceSession(
      id: id,
      userId: userId,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      organizationId: organizationId,
      teamId: teamId,
      startLocation: startLocation,
      endLocation: endLocation ?? this.endLocation,
    );
  }

  factory AttendanceSession.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final Timestamp? startTimestamp = data['startTime'] as Timestamp?;
    final Timestamp? endTimestamp = data['endTime'] as Timestamp?;
    return AttendanceSession(
      id: id,
      userId: data['userId'] as String? ?? '',
      startTime: (startTimestamp ?? Timestamp.now()).toDate(),
      endTime: endTimestamp?.toDate(),
      organizationId: data['organizationId'] as String?,
      teamId: data['teamId'] as String?,
      startLocation: data['startLocation'] as GeoPoint?,
      endLocation: data['endLocation'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'teamId': teamId,
      'startTime': Timestamp.fromDate(startTime),
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime!),
      if (startLocation != null) 'startLocation': startLocation,
      if (endLocation != null) 'endLocation': endLocation,
    };
  }
}
