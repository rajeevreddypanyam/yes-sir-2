import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_session.dart';

class AttendanceService {
  AttendanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('attendanceSessions');

  Stream<AttendanceSession?> watchActiveSession(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('endTime', isNull: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      final doc = snapshot.docs.first;
      return AttendanceSession.fromFirestore(doc.id, doc.data());
    });
  }

  Stream<List<AttendanceSession>> watchRecentSessions(
    String userId, {
    int limit = 10,
  }) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceSession.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<String> startSession({
    required String userId,
    String? organizationId,
    String? teamId,
    GeoPoint? startLocation,
  }) async {
    final doc = _collection.doc();
    await doc.set({
      'userId': userId,
      'organizationId': organizationId,
      'teamId': teamId,
      'startTime': FieldValue.serverTimestamp(),
      'startLocation': startLocation,
      'status': 'active',
    });
    return doc.id;
  }

  Future<void> endSession({
    required String sessionId,
    GeoPoint? endLocation,
  }) async {
    await _collection.doc(sessionId).update({
      'endTime': FieldValue.serverTimestamp(),
      'endLocation': endLocation,
      'status': 'completed',
    });
  }
}
