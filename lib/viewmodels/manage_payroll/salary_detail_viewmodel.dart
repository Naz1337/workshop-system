import 'package:flutter/foundation.dart';
import '../../repositories/payroll_repository.dart';
import '../../models/payroll_model.dart';
import '../../services/payment_api_service.dart';
import 'dart:io';

// ViewModel for salary detail and payment processing
class SalaryDetailViewModel extends ChangeNotifier {
  final PayrollRepository _payrollRepo;
  final PaymentAPIService _paymentService;
  final Payroll initialPayroll;

  SalaryDetailViewModel({
    required PayrollRepository payrollRepo,
    required PaymentAPIService paymentService,
    required this.initialPayroll,
  })  : _payrollRepo = payrollRepo,
        _paymentService = paymentService;

  bool _isProcessing = false;
  String? _error;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  
  // Process the payment and update Firestore
  Future<bool> processPayment(double amount, double hours, String method) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPayroll = initialPayroll.copyWith(
        amount: amount,
        hoursWorked: hours,
        paymentMethod: method,
        timestamp: DateTime.now(),
        status: 'Paid',
      );

      // Call payment API service
      final paymentSuccess = await _paymentService.processPayment(
      amount: updatedPayroll.amount,
      method: updatedPayroll.paymentMethod,
      recipient: updatedPayroll.foremanId,
);

      // Check API result
      if (!paymentSuccess) {
        _error = 'Payment declined';
        return false;
      }

      // Save updated payroll to Firestore
      await _payrollRepo.savePayroll(updatedPayroll);
      return true;
    } on SocketException {
      _error = 'Connection error';
    } catch (e) {
      _error = 'Unexpected error: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
    return false;
  }
}