import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_system/models/payroll_model.dart';

class PayrollService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Payroll>> getPendingPayrolls() {
    return _db.collection('payrolls')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payroll(
                  id: doc.id,
                  foremanId: doc['foremanId'],
                  amount: doc['amount'],
                  hoursWorked: doc['hoursWorked'],
                  paymentMethod: doc['paymentMethod'],
                  status: doc['status'],
                  timestamp: (doc['timestamp'] as Timestamp).toDate(),
                ))
            .toList());
  }

  Future<void> addPayroll(Payroll payroll) async {
    await _db.collection('payrolls').add(payroll.toMap());
  }

  Future<void> updatePayrollStatus(String id, String status) async {
    await _db.collection('payrolls').doc(id).update({'status': status});
  }
}