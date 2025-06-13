// lib/views/manage_payroll/pending_payroll_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/viewmodels/manage_payroll/pending_payroll_viewmodel.dart';
import 'salary_detail_view.dart';
import '../../models/foreman_model.dart';

/// Displays a list of all foremen with options to process salary payments or delete payrolls.
class PendingPayrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Payroll')),
      body: Consumer<PendingPayrollViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          if (viewModel.foremen.isEmpty) {
            return const Center(child: Text('No foremen available.'));
          }

          return ListView.builder(
            itemCount: viewModel.foremen.length,
            itemBuilder: (context, index) {
              final foreman = viewModel.foremen[index];
              return ListTile(
                title: Text('Foreman: ${foreman.foremanName}'),
                subtitle: Text('Bank Account No: ${foreman.foremanBankAccountNo}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.payment),
                      onPressed: () => _navigateToSalaryDetail(context, foreman),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Navigate to SalaryDetailView with selected foreman
  void _navigateToSalaryDetail(BuildContext context, Foreman foreman) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalaryDetailView(foreman: foreman),
      ),
    );
  }

}
