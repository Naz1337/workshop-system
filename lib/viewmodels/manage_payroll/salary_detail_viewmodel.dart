// lib/viewmodels/manage_payroll/salary_detail_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../models/payroll_model.dart';
import '../../repositories/payroll_repository.dart';

class SalaryDetailViewModel extends ChangeNotifier {
  final PayrollRepository _payrollRepository;
  final Payroll payroll;

  SalaryDetailViewModel({
    required PayrollRepository payrollRepository,
    required this.payroll,
  }) : _payrollRepository = payrollRepository;

  String _selectedMethod = 'DuitNow';
  String get selectedMethod => _selectedMethod;
  set selectedMethod(String value) {
    _selectedMethod = value;
    notifyListeners();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _paymentError;
  String? get paymentError => _paymentError;
  // To reset error after displaying
  void clearPaymentError() {
    _paymentError = null;
    // notifyListeners(); // Optional: depends on how you handle UI updates
  }


  bool _paymentSuccessful = false;
  bool get paymentSuccessful => _paymentSuccessful;

  Future<void> processPayment() async {
    _isProcessing = true;
    _paymentError = null;
    _paymentSuccessful = false;
    notifyListeners();
    try {
      await _payrollRepository.confirmPayment(payroll, _selectedMethod);
      _paymentSuccessful = true;
    } catch (e) {
      _paymentError = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
