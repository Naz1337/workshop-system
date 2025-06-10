import 'package:flutter/foundation.dart';
import '../../repositories/payroll_repository.dart';
import '../../models/payroll_model.dart';
import '../../services/payment_api_service.dart';
import 'dart:io';


// ViewModel for salary detail screen using MVVM architecture.
// Manages payment logic, error handling, and Firestore integration.
class SalaryDetailViewModel extends ChangeNotifier {
  final PayrollRepository payrollRepo;
  PaymentAPIService? paymentService;

  //constuctor
  SalaryDetailViewModel({required this.payrollRepo,this.paymentService,});

  bool _isProcessing = false;
  String? _error;

  // Public getters for UI state binding
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  

  /// Injects the selected payment API service at runtime
  void setPaymentService(PaymentAPIService service) {
    paymentService = service;
    notifyListeners();
  }

  /// Processes a payment and stores the result in Firestore
  Future<bool> processPayroll(Payroll payroll) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      if (paymentService == null) {
        _error = 'Payment method not selected.';
        return false;
      }

      final paymentSuccess = await paymentService!.processPayment(
        amount: payroll.amount,
        method: payroll.paymentMethod,
        recipient: payroll.foremanId,
      );

      if (!paymentSuccess) {
        _error = 'Payment failed';
        return false;
      }

      await payrollRepo.savePayroll(payroll); // Save after payment
      return true;
      
    } on SocketException {
      _error = 'No internet connection';
    } catch (e) {
      _error = 'Unexpected error: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }

    return false;
  }
}
