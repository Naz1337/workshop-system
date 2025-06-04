// lib/views/manage_payroll/salary_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payroll_model.dart';
import '../../repositories/payroll_repository.dart';
import '../../viewmodels/manage_payroll/salary_detail_viewmodel.dart';

class SalaryDetailView extends StatelessWidget {
  final Payroll payroll;

  const SalaryDetailView({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SalaryDetailViewModel(
        payrollRepository: Provider.of<PayrollRepository>(context, listen: false),
        payroll: payroll,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Salary Details')),
        body: Builder( // Use Builder to get a new context
          builder: (context) {
            // Listen to changes in SalaryDetailViewModel
            final viewModel = Provider.of<SalaryDetailViewModel>(context);

            // Handle side effects
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.paymentSuccessful) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context, true); // Pop and indicate success
              } else if (viewModel.paymentError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${viewModel.paymentError}'), backgroundColor: Colors.red),
                );
                viewModel.clearPaymentError(); // Clear error after showing
              }
            });

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foreman ID: ${viewModel.payroll.foremanId}'),
                  Text('Foreman Name: ${viewModel.payroll.foremanName}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Salary Amount: RM ${viewModel.payroll.salary.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                  Text('Created At: ${viewModel.payroll.createdAt.toLocal().toString().substring(0,16)}'), // Format date
                  const SizedBox(height: 24),
                  const Text('Select Payment Method:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: viewModel.selectedMethod,
                    isExpanded: true,
                    onChanged: viewModel.isProcessing
                        ? null
                        : (value) {
                            if (value != null) {
                              viewModel.selectedMethod = value;
                            }
                          },
                    items: ['DuitNow', 'iPay88']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          onPressed: () => viewModel.processPayment(),
                          label: const Text('Confirm Payment'),
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
