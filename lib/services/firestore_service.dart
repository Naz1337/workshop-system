import 'package:cloud_firestore/cloud_firestore.dart';

enum QueryOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}

class QueryCondition {
  final String field;
  final QueryOperator operator;
  final dynamic value;

  QueryCondition({required this.field, required this.operator, this.value});
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getDocument({required String collectionPath, required String documentId}) async {
    return await _db.collection(collectionPath).doc(documentId).get();
  }

  Future<QuerySnapshot> getCollection({
    required String collectionPath,
    List<QueryCondition>? conditions,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _db.collection(collectionPath);

    if (conditions != null) {
      for (var condition in conditions) {
        switch (condition.operator) {
          case QueryOperator.isEqualTo:
            query = query.where(condition.field, isEqualTo: condition.value);
            break;
          case QueryOperator.isNotEqualTo:
            query = query.where(condition.field, isNotEqualTo: condition.value);
            break;
          case QueryOperator.isLessThan:
            query = query.where(condition.field, isLessThan: condition.value);
            break;
          case QueryOperator.isLessThanOrEqualTo:
            query = query.where(condition.field, isLessThanOrEqualTo: condition.value);
            break;
          case QueryOperator.isGreaterThan:
            query = query.where(condition.field, isGreaterThan: condition.value);
            break;
          case QueryOperator.isGreaterThanOrEqualTo:
            query = query.where(condition.field, isGreaterThanOrEqualTo: condition.value);
            break;
          case QueryOperator.arrayContains:
            query = query.where(condition.field, arrayContains: condition.value);
            break;
          case QueryOperator.arrayContainsAny:
            query = query.where(condition.field, arrayContainsAny: condition.value);
            break;
          case QueryOperator.whereIn:
            query = query.where(condition.field, whereIn: condition.value);
            break;
          case QueryOperator.whereNotIn:
            query = query.where(condition.field, whereNotIn: condition.value);
            break;
          case QueryOperator.isNull:
            query = query.where(condition.field, isNull: condition.value);
            break;
        }
      }
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

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

  Stream<QuerySnapshot> streamCollection({
    required String collectionPath,
    List<QueryCondition>? conditions,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query query = _db.collection(collectionPath);

    if (conditions != null) {
      for (var condition in conditions) {
        switch (condition.operator) {
          case QueryOperator.isEqualTo:
            query = query.where(condition.field, isEqualTo: condition.value);
            break;
          case QueryOperator.isNotEqualTo:
            query = query.where(condition.field, isNotEqualTo: condition.value);
            break;
          case QueryOperator.isLessThan:
            query = query.where(condition.field, isLessThan: condition.value);
            break;
          case QueryOperator.isLessThanOrEqualTo:
            query = query.where(condition.field, isLessThanOrEqualTo: condition.value);
            break;
          case QueryOperator.isGreaterThan:
            query = query.where(condition.field, isGreaterThan: condition.value);
            break;
          case QueryOperator.isGreaterThanOrEqualTo:
            query = query.where(condition.field, isGreaterThanOrEqualTo: condition.value);
            break;
          case QueryOperator.arrayContains:
            query = query.where(condition.field, arrayContains: condition.value);
            break;
          case QueryOperator.arrayContainsAny:
            query = query.where(condition.field, arrayContainsAny: condition.value);
            break;
          case QueryOperator.whereIn:
            query = query.where(condition.field, whereIn: condition.value);
            break;
          case QueryOperator.whereNotIn:
            query = query.where(condition.field, whereNotIn: condition.value);
            break;
          case QueryOperator.isNull:
            query = query.where(condition.field, isNull: condition.value);
            break;
        }
      }
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  Stream<DocumentSnapshot> streamDocument({required String collectionPath, required String documentId}) {
    return _db.collection(collectionPath).doc(documentId).snapshots();
  }
}
