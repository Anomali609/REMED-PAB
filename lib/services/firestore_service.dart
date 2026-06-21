import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- USERS ----------------
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'instagram': '-',
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // ---------------- FAVORITES ----------------
  Future<bool> isFavorite(String uid, int articleId) async {
    final snap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .where('articleId', isEqualTo: articleId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> addFavorite({
    required String uid,
    required int articleId,
    required String title,
    required String imageUrl,
    required String newsSite,
  }) {
    return _db.collection('favorites').add({
      'userId': uid,
      'articleId': articleId,
      'title': title,
      'imageUrl': imageUrl,
      'newsSite': newsSite,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String uid, int articleId) async {
    final snap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .where('articleId', isEqualTo: articleId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFavorites(String uid) {
    return _db
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .orderBy('savedAt', descending: true)
        .snapshots();
  }
}
