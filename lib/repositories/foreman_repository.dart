import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/foreman_model.dart';
import '../services/firestore_service.dart';

class ForemanRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'foremen';

  ForemanRepository(this._firestoreService);

  Future<Foreman?> getForeman(String foremanId) async {
    try {
      DocumentSnapshot doc = await _firestoreService.getDocument(
          collectionPath: _collectionPath, documentId: foremanId);
      if (doc.exists) {
        return Foreman.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error getting foreman: $e');
    }
    return null;
  }

  Future<void> addForeman(Foreman foreman) async {
    try {
      await _firestoreService.addDocument(
          collectionPath: _collectionPath, data: foreman.toMap());
    } catch (e) {
      print('Error adding foreman: $e');
    }
  }

  Future<void> updateForeman(Foreman foreman) async {
    try {
      await _firestoreService.updateDocument(
          collectionPath: _collectionPath,
          documentId: foreman.id,
          data: foreman.toMap());
    } catch (e) {
      print('Error updating foreman: $e');
    }
  }

  Future<void> deleteForeman(String foremanId) async {
    try {
      await _firestoreService.deleteDocument(
          collectionPath: _collectionPath, documentId: foremanId);
    } catch (e) {
      print('Error deleting foreman: $e');
    }
  }

  Stream<Foreman?> streamForeman(String foremanId) {
    return _firestoreService
        .streamDocument(collectionPath: _collectionPath, documentId: foremanId)
        .map((doc) {
      if (doc.exists) {
        return Foreman.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  Stream<List<Foreman>> streamAllForemen() {
    return _firestoreService
        .streamCollection(collectionPath: _collectionPath)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Foreman.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
