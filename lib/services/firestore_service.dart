import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper class for query conditions (e.g., where, orderBy)
  // This is a placeholder and would need to be defined elsewhere
  // class QueryCondition {
  //   final String field;
  //   final dynamic value;
  //   final QueryOp operator; // e.g., ==, <, >, <=, >=
  //   QueryCondition(this.field, this.value, this.operator);
  // }
  // enum QueryOp { equal, lessThan, greaterThan, lessThanOrEqual, greaterThanOrEqual }

  Future<DocumentSnapshot> getDocument({required String collectionPath, required String documentId}) async {
    return await _db.collection(collectionPath).doc(documentId).get();
  }

  Future<QuerySnapshot> getCollection({required String collectionPath, List<dynamic>? conditions}) async {
    // Placeholder for conditions. Actual implementation would parse QueryCondition objects.
    Query query = _db.collection(collectionPath);
    // Example: if (conditions != null) {
    //   for (var condition in conditions) {
    //     query = query.where(condition.field, isEqualTo: condition.value);
    //   }
    // }
    return await query.get();
  }

  Future<DocumentReference> addDocument({required String collectionPath, required Map<String, dynamic> data}) async {
    return await _db.collection(collectionPath).add(data);
  }

  Future<void> setDocument({required String collectionPath, required String documentId, required Map<String, dynamic> data}) async {
    await _db.collection(collectionPath).doc(documentId).set(data);
  }

  Future<void> updateDocument({required String collectionPath, required String documentId, required Map<String, dynamic> data}) async {
    await _db.collection(collectionPath).doc(documentId).update(data);
  }

  Future<void> deleteDocument({required String collectionPath, required String documentId}) async {
    await _db.collection(collectionPath).doc(documentId).delete();
  }

  Stream<QuerySnapshot> streamCollection({required String collectionPath, List<dynamic>? conditions}) {
    // Placeholder for conditions. Actual implementation would parse QueryCondition objects.
    Query query = _db.collection(collectionPath);
    // Example: if (conditions != null) {
    //   for (var condition in conditions) {
    //     query = query.where(condition.field, isEqualTo: condition.value);
    //   }
    // }
    return query.snapshots();
  }

  Stream<DocumentSnapshot> streamDocument({required String collectionPath, required String documentId}) {
    return _db.collection(collectionPath).doc(documentId).snapshots();
  }
}
