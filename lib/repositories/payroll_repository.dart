// lib/repositories/payroll_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/payroll_model.dart';
import '../models/foreman_model.dart';

class PayrollRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestore;
   final String _collectionPath = 'payrolls';
  

  PayrollRepository(this._firestore);

  // Stream all foremen (no status filtering)
  Stream<List<Foreman>> getAllForemen() {
    return _firestore
        .streamCollection(collectionPath: 'foremen')
        .map((snapshot) => snapshot.docs
            .map((doc) => Foreman.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Add new payroll entry to Firestore
  Future<void> addPayroll(Payroll payroll) async {
    await _firestore.addDocument(
      collectionPath: _collectionPath,
      data: payroll.toMap(),
    );
  }

  // Save (or overwrite) a payroll with specific ID
  Future<void> savePayroll(Payroll payroll) async {
   try {
    await _firestore.setDocument(
      collectionPath: _collectionPath,
      documentId: payroll.id,
      data: payroll.toMap(),
    );
   } catch (e) {
      print('Error creating foreman profile: $e');
    }
  }
}
