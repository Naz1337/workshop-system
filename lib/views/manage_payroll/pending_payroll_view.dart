// lib/views/manage_payroll/pending_payroll_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/services/payment_api_service.dart';
import 'package:workshop_system/services/payroll_service.dart';
import '../../viewmodels/manage_payroll/pending_payroll_viewmodel.dart';
import '../../models/payroll_model.dart';
import '../../viewmodels/manage_payroll/salary_detail_viewmodel.dart';
import 'salary_detail_view.dart';


class PendingPayrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Payroll')),
      body: Consumer<PendingPayrollViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }
          
          return ListView.builder(
            itemCount: viewModel.payrolls.length,
            itemBuilder: (context, index) {
              final payroll = viewModel.payrolls[index];
              return ListTile(
                title: Text('Foreman: ${payroll.foremanId}'),
                subtitle: Text('Amount: RM${payroll.amount.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.payment),
                      onPressed: () => _navigateToSalaryDetail(context, payroll),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, payroll),
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

  void _navigateToSalaryDetail(BuildContext context, Payroll payroll) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalaryDetailView(payroll: payroll),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Payroll payroll) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Remove this payroll record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement soft delete if needed
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}