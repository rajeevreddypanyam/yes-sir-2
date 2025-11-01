import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  Future<AppUser?> fetchUserProfile(String uid) async {
    final snapshot = await _collection.doc(uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return AppUser.fromJson(snapshot.id, data);
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _collection.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return AppUser.fromJson(snapshot.id, data);
    });
  }

  Future<void> upsertUserProfile(AppUser user) {
    return _collection.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }
}
