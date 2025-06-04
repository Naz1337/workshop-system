// lib/repositories/payroll_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payroll_model.dart'; // Updated import

class PayrollRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Payroll>> fetchPendingPayrolls() async {
    final snapshot = await _db.collection('payrolls')
      .where('isPaid', isEqualTo: false)
      .get();
    // Ensure createdAt is handled correctly if it's a Timestamp from Firestore
    return snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id; // Assuming 'id' should be the document ID
      // If 'createdAt' is a Timestamp, convert it:
      // if (data['createdAt'] is Timestamp) {
      //   data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      // }
      return Payroll.fromJson(data);
    }).toList();
  }

  Future<void> confirmPayment(Payroll payroll, String method) async {
    try {
      final response = await _simulatePaymentAPI(method); // Made private

      if (response == 'success') {
        await _db.collection('payrolls').doc(payroll.id).update({
          'isPaid': true,
          'paymentMethod': method, // Optionally store payment method
          'paidAt': FieldValue.serverTimestamp(), // Optionally store payment time
        });
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Private helper method
  Future<String> _simulatePaymentAPI(String method) async {
    await Future.delayed(const Duration(seconds: 2));
    if (method == 'DuitNow' || method == 'iPay88') {
      return 'success';
    } else {
      return 'Payment Declined';
    }
  }
}
