import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workshop_model.dart';
import '../services/firestore_service.dart';
import '../repositories/user_repository.dart'; // Import UserRepository

class WorkshopRepository {
  final FirestoreService _firestoreService;
  final UserRepository _userRepository; // Add UserRepository
  final String _collectionPath = 'workshops';

  WorkshopRepository(this._firestoreService, this._userRepository); // Update constructor

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
      // Fetch owner's name and assign to workshopName before saving
      if (workshop.ownerId != null) {
        final owner = await _userRepository.getUser(workshop.ownerId!);
        if (owner != null) {
          workshop = workshop.copyWith(workshopName: owner.name);
        }
      }
      await _firestoreService.setDocument(
          collectionPath: _collectionPath, documentId: workshop.id, data: workshop.toMap());
    } catch (e) {
      print('Error creating workshop: $e');
    }
  }

  Future<void> updateWorkshop(Workshop workshop) async {
    try {
      // Fetch owner's name and assign to workshopName before updating
      if (workshop.ownerId != null) {
        final owner = await _userRepository.getUser(workshop.ownerId!);
        if (owner != null) {
          workshop = workshop.copyWith(workshopName: owner.name);
        }
      }
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

  Future<List<Workshop>> searchWorkshops({String? query}) async {
    try {
      List<QueryCondition> conditions = [];
      if (query != null && query.isNotEmpty) {
        // For a basic search, we'll search by workshopName.
        // Firestore's `where` clause for string matching is prefix-based.
        // To implement a "contains" search, you'd typically need a third-party search service
        // or a more complex setup with Cloud Functions and a dedicated search index.
        // For now, we'll do a starts-with search on workshopName.
        conditions.add(QueryCondition(
          field: 'workshopName',
          operator: QueryOperator.isGreaterThanOrEqualTo,
          value: query,
        ));
        conditions.add(QueryCondition(
          field: 'workshopName',
          operator: QueryOperator.isLessThanOrEqualTo,
          value: query + '\uf8ff',
        ));
      }

      QuerySnapshot snapshot = await _firestoreService.getCollection(
        collectionPath: _collectionPath,
        conditions: conditions,
      );

      return snapshot.docs
          .map((doc) => Workshop.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error searching workshops: $e');
      return [];
    }
  }
}
