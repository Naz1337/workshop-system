// lib/viewmodels/pending_payroll_viewmodel.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workshop_system/services/payment_api_service.dart';
import 'package:workshop_system/services/payroll_service.dart';
import '../../repositories/payroll_repository.dart';
import '../../models/payroll_model.dart';


class PendingPayrollViewModel with ChangeNotifier {
  late PayrollRepository _payrollRepo;
  late PaymentServiceFactory _paymentServiceFactory;
  List<Payroll> _payrolls = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Payroll> get payrolls => _payrolls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PendingPayrollViewModel(this._payrollRepo, this._paymentServiceFactory) {
    _loadPayrolls();
  }

  void _loadPayrolls() {
    _isLoading = true;
    notifyListeners();
    
    _payrollRepo.getPendingPayrolls().listen((payrolls) {
      _payrolls = payrolls;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load payrolls: $error';
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> processPayment(Payroll payroll) async {
    try {
      final service = _paymentServiceFactory.getService(payroll.paymentMethod);
      final success = await service.processPayment(
        amount: payroll.amount,
        method: payroll.paymentMethod,
        recipient: payroll.foremanId,
      );

      if (success) {
        // Update status in Firestore
        await _payrollRepo.addPayroll(payroll.copyWith(status: 'Paid'));
      } else {
        throw Exception('Payment processing failed');
      }
    } on SocketException {
      throw Exception('Connection error. Please check your network');
    } catch (e) {
      throw Exception('Payment failed: ${e.toString()}');
    }
  }
}
