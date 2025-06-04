import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user_model.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'users';

  UserRepository(this._firestoreService);

  Future<AppUser?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestoreService.getDocument(
          collectionPath: _collectionPath, documentId: userId);
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  Future<void> createUserDocument(AppUser user) async {
    try {
      await _firestoreService.setDocument(
          collectionPath: _collectionPath, documentId: user.id, data: user.toMap());
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await _firestoreService.updateDocument(
          collectionPath: _collectionPath,
          documentId: user.id,
          data: user.toMap());
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteDocument(
          collectionPath: _collectionPath, documentId: userId);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Stream<AppUser?> streamUser(String userId) {
    return _firestoreService
        .streamDocument(collectionPath: _collectionPath, documentId: userId)
        .map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  Stream<List<AppUser>> streamAllUsers() {
    return _firestoreService
        .streamCollection(collectionPath: _collectionPath)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
