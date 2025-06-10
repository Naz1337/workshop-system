import 'package:flutter/foundation.dart';
import '../../repositories/payroll_repository.dart';
import '../../models/payroll_model.dart';
import '../../services/payment_api_service.dart';
import 'dart:io';

enum PaymentStatus { initial, processing, success, failure }

// ViewModel for salary detail screen using MVVM architecture.
// Manages payment logic, error handling, and Firestore integration.
class SalaryDetailViewModel extends ChangeNotifier {
  final PayrollRepository payrollRepo;
  PaymentAPIService? paymentService;

  //constuctor
  SalaryDetailViewModel({required this.payrollRepo,this.paymentService,});

  bool _isProcessing = false;
  String? _error;
  PaymentStatus _paymentStatus = PaymentStatus.initial;

  // Public getters for UI state binding
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  PaymentStatus get paymentStatus => _paymentStatus;
  

  /// Injects the selected payment API service at runtime
  void setPaymentService(PaymentAPIService service) {
    paymentService = service;
    notifyListeners();
  }

  /// Processes a payment and stores the result in Firestore
  Future<void> processPayroll(Payroll payroll) async {
    _isProcessing = true;
    _error = null;
    _paymentStatus = PaymentStatus.processing;
    notifyListeners();

    try {
      if (paymentService == null) {
        _error = 'Payment method not selected.';
        _paymentStatus = PaymentStatus.failure;
        notifyListeners();
        return;
      }

      final paymentSuccess = await paymentService!.processPayment(
        amount: payroll.amount,
        method: payroll.paymentMethod,
        recipient: payroll.foremanId,
      );

      if (!paymentSuccess) {
        _error = 'Payment failed';
        _paymentStatus = PaymentStatus.failure;
        notifyListeners();
        return;
      }

      await payrollRepo.savePayroll(payroll); // Save after payment
      _paymentStatus = PaymentStatus.success;
      
    } on SocketException {
      _error = 'No internet connection';
      _paymentStatus = PaymentStatus.failure;
    } catch (e) {
      _error = 'Unexpected error: $e';
      _paymentStatus = PaymentStatus.failure;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
