// lib/viewmodels/manage_payroll/pending_payroll_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../models/payroll_model.dart';
import '../../repositories/payroll_repository.dart';

class PendingPayrollViewModel extends ChangeNotifier {
  final PayrollRepository _payrollRepository;

  PendingPayrollViewModel({required PayrollRepository payrollRepository})
      : _payrollRepository = payrollRepository;

  List<Payroll> _payrolls = [];
  List<Payroll> get payrolls => _payrolls;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadPendingPayrolls() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify loading start
    try {
      _payrolls = await _payrollRepository.fetchPendingPayrolls();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify loading end and data/error update
    }
  }
}
