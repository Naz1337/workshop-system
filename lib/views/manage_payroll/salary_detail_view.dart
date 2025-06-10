// lib/views/manage_payroll/salary_detail_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/foreman_model.dart';
import '../../models/payroll_model.dart';
import '../../repositories/payroll_repository.dart';
import '../../services/payment_api_service.dart';
import '../../viewmodels/manage_payroll/salary_detail_viewmodel.dart';

/// The main view for entering salary details and processing payroll payment.
class SalaryDetailView extends StatelessWidget {
  final Foreman foreman;
  

  const SalaryDetailView({Key? key, required this.foreman}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final payrollRepo = Provider.of<PayrollRepository>(context, listen: false);

    // Provide only the repository; service will be set later based on selected payment method
    return ChangeNotifierProvider<SalaryDetailViewModel>(
      create: (_) => SalaryDetailViewModel(
        payrollRepo: payrollRepo,
        paymentService: null, // Set later when method selected
      ),
      child: _SalaryDetailForm(foreman: foreman),
    );
  }
}
/// Internal form widget for entering and confirming salary payment.
class _SalaryDetailForm extends StatefulWidget {
  final Foreman foreman;

  const _SalaryDetailForm({Key? key, required this.foreman}) : super(key: key);
  
  @override
  State<_SalaryDetailForm> createState() => _SalaryDetailFormState();
}

class _SalaryDetailFormState extends State<_SalaryDetailForm> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  double _hours = 0.0;
  String _paymentMethod = 'DuitNow';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SalaryDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Pay ${widget.foreman.foremanName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Error message if exists
              if (viewModel.error != null)
                Text(viewModel.error!, style: const TextStyle(color: Colors.red)),

              // Amount field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount (RM)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),

              // Hours field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Hours Worked'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter hours';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
                onSaved: (value) => _hours = double.parse(value!),
              ),

              // Dropdown for payment method
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['DuitNow', 'IPay88'].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),

              const SizedBox(height: 20),

              // Submit button
              viewModel.isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _submitForm(context, viewModel),
                      child: const Text('Process Payment'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Validates and submits the form. Shows confirmation dialog.
  void _submitForm(BuildContext context, SalaryDetailViewModel viewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Payment'),
          content: Text(
              'Pay RM${_amount.toStringAsFixed(2)} to ${widget.foreman.foremanName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Inject correct payment service based on selected method
                final paymentService = Provider.of<PaymentServiceFactory>(
                  context,
                  listen: false,
                ).getService(_paymentMethod);

                viewModel.setPaymentService(paymentService);

                //Generate Firestore document ID
                final generatedId = FirebaseFirestore.instance.collection('payrolls').doc().id;

                // Build a Payroll object
                final payroll = Payroll(
                  id: generatedId, 
                  foremanId: widget.foreman.id,
                  amount: _amount,
                  hoursWorked: _hours,
                  paymentMethod: _paymentMethod,
                  timestamp: DateTime.now(),
                  status: 'pending',
                );

                final success = await viewModel.processPayroll(payroll);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment successful!')),
                  );
                  Navigator.pop(context); // Go back
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(viewModel.error ?? 'Payment failed.')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
}
