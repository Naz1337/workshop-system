// lib/views/manage_payroll/pending_payroll_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payroll_model.dart';
import '../../repositories/payroll_repository.dart';
import '../../viewmodels/manage_payroll/pending_payroll_viewmodel.dart';
import 'package:go_router/go_router.dart'; // Import go_router

class PendingPayrollView extends StatelessWidget {
  const PendingPayrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PendingPayrollViewModel(
        payrollRepository: Provider.of<PayrollRepository>(context, listen: false),
      )..loadPendingPayrolls(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Pending Payrolls')),
        body: Consumer<PendingPayrollViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null) {
              return Center(child: Text('Error: ${viewModel.error}'));
            }
            if (viewModel.payrolls.isEmpty) {
              return const Center(child: Text('No pending payrolls.'));
            }

            final items = viewModel.payrolls;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final payroll = items[index];
                return ListTile(
                  title: Text(payroll.foremanName),
                  subtitle: Text('RM ${payroll.salary.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Use context.push with the new path and pass payroll as extra
                    context.push<bool>(
                      '/manage-payroll/salary-detail',
                      extra: payroll,
                    ).then((paymentMade) {
                      // If SalaryDetailView pops with `true` after successful payment,
                      // then refresh the list.
                      if (paymentMade == true) {
                        viewModel.loadPendingPayrolls();
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
