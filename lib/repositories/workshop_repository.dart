import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workshop_model.dart';
import '../services/firestore_service.dart';

class WorkshopRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'workshops';

  WorkshopRepository(this._firestoreService);

  Future<Workshop?> getWorkshop(String workshopId) async {
    try {
      DocumentSnapshot doc = await _firestoreService.getDocument(
          collectionPath: _collectionPath, documentId: workshopId);
      if (doc.exists) {
        return Workshop.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error getting workshop: $e');
    }
    return null;
  }

  Future<void> createWorkshop(Workshop workshop) async {
    try {
      await _firestoreService.setDocument(
          collectionPath: _collectionPath, documentId: workshop.id, data: workshop.toMap());
    } catch (e) {
      print('Error creating workshop: $e');
    }
  }

  Future<void> updateWorkshop(Workshop workshop) async {
    try {
      await _firestoreService.updateDocument(
          collectionPath: _collectionPath,
          documentId: workshop.id,
          data: workshop.toMap());
    } catch (e) {
      print('Error updating workshop: $e');
    }
  }

  Future<void> deleteWorkshop(String workshopId) async {
    try {
      await _firestoreService.deleteDocument(
          collectionPath: _collectionPath, documentId: workshopId);
    } catch (e) {
      print('Error deleting workshop: $e');
    }
  }

  Stream<Workshop?> streamWorkshop(String workshopId) {
    return _firestoreService
        .streamDocument(collectionPath: _collectionPath, documentId: workshopId)
        .map((doc) {
      if (doc.exists) {
        return Workshop.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  Stream<List<Workshop>> streamAllWorkshops() {
    return _firestoreService
        .streamCollection(collectionPath: _collectionPath)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Workshop.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
