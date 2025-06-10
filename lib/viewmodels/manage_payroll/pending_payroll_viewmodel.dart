// lib/viewmodels/pending_payroll_viewmodel.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/foreman_model.dart';
import '../../models/payroll_model.dart';
import '../../repositories/payroll_repository.dart';
import '../../services/payment_api_service.dart';

class PendingPayrollViewModel extends ChangeNotifier {
  final PayrollRepository _payrollRepo;
  final PaymentServiceFactory _paymentServiceFactory;

  List<Foreman> _foremen = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Foreman> get foremen => _foremen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  PendingPayrollViewModel(this._payrollRepo, this._paymentServiceFactory) {
    _loadForemen();
  }

  // Loads the list of all foremen from the repository.
  // Updates UI state via notifyListeners().
  void _loadForemen() {
    _isLoading = true;
    notifyListeners();

    _payrollRepo.getAllForemen().listen(
      (foremanList) {
        _foremen = foremanList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load foremen: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Processes payroll payment using the selected payment method,
  // then saves the payroll as 'Paid' in Firestore if successful.
  Future<void> processPayment(Payroll payroll) async {
    try {
      final service =
          _paymentServiceFactory.getService(payroll.paymentMethod);

      final success = await service.processPayment(
        amount: payroll.amount,
        method: payroll.paymentMethod,
        recipient: payroll.foremanId,
      );

      if (success) {
        await _payrollRepo.addPayroll(
          payroll.copyWith(status: 'Paid'),
        );
      } else {
        throw Exception('Payment processing failed');
      }
    } on SocketException {
      throw Exception('Connection error. Please check your network');
    } catch (e) {
      throw Exception('Payment failed: ${e.toString()}');
    }
  }

  Future<void> deletePayrollForForeman(String foremanId) async {
  try {
    // Delete all payrolls with this foremanId and status 'Pending'
    final snapshot = await FirebaseFirestore.instance
        .collection('payrolls')
        .where('foremanId', isEqualTo: foremanId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Reload foremen
    _loadForemen();
  } catch (e) {
    _errorMessage = 'Failed to delete payroll: $e';
    notifyListeners();
  }
}
  
}


