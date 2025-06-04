import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/payroll.dart';

class PayrollController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Payroll>> fetchPendingPayrolls() async {
    final snapshot = await _db.collection('payrolls')
      .where('isPaid', isEqualTo: false)
      .get();
    return snapshot.docs.map((doc) => Payroll.fromJson(doc.data())).toList();
  }

  Future<void> confirmPayment(Payroll payroll, String method) async {
    try {
      // Simulate payment API integration with DuitNow or iPay88
      final response = await simulatePaymentAPI(method);

      if (response == 'success') {
        await _db.collection('payrolls').doc(payroll.id).update({
          'isPaid': true
        });
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> simulatePaymentAPI(String method) async {
    await Future.delayed(Duration(seconds: 2));
    if (method == 'DuitNow' || method == 'iPay88') {
      return 'success';
    } else {
      return 'Payment Declined';
    }
  }
}

