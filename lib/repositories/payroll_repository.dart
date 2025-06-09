// lib/repositories/payroll_repository.dart
import '../services/firestore_service.dart';
import '../models/payroll_model.dart';

class PayrollRepository {
  final FirestoreService _firestore;

  PayrollRepository(this._firestore);

  Stream<List<Payroll>> getPendingPayrolls() {
    return _firestore.streamCollection(
      collectionPath: 'payrolls',
      conditions: [
        QueryCondition(
          field: 'status', 
          operator: QueryOperator.isEqualTo, 
          value: 'Pending'
        ),
      ],
    ).map((snapshot) => snapshot.docs
        .map((doc) => Payroll.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addPayroll(Payroll payroll) async {
    await _firestore.addDocument(
      collectionPath: 'payrolls',
      data: payroll.toMap(),
    );
  }

  Future<void> savePayroll(Payroll payroll) async {
  await _firestore.setDocument(
    collectionPath: 'payrolls',
    documentId: payroll.id,
    data: payroll.toMap(),
  );
}
}