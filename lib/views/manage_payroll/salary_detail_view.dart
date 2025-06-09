
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/models/payroll_model.dart';
import 'package:workshop_system/repositories/payroll_repository.dart';
import 'package:workshop_system/services/payment_api_service.dart';
import 'package:workshop_system/viewmodels/manage_payroll/salary_detail_viewmodel.dart';
import 'package:go_router/go_router.dart';

// -----------------------------
// SalaryDetailView (Root View)
// -----------------------------
class SalaryDetailView extends StatelessWidget {
  final Payroll payroll; // Incoming data from routing (GoRouter.extra)

  const SalaryDetailView({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    // Get dependencies (Repository + Payment Service)
    final payrollRepo = Provider.of<PayrollRepository>(context, listen: false);
    final paymentService = Provider.of<PaymentServiceFactory>(context, listen: false)
        .getService(payroll.paymentMethod);

    // Inject the SalaryDetailViewModel for this screen using ChangeNotifierProvider
    return ChangeNotifierProvider<SalaryDetailViewModel>(
      create: (_) => SalaryDetailViewModel(
        payrollRepo: payrollRepo,
        paymentService: paymentService,
        initialPayroll: payroll,
      ),
      child: const _SalaryDetailForm(),
    );
  }
}

// -----------------------------------
// _SalaryDetailForm (Inner Form View)
// -----------------------------------
class _SalaryDetailForm extends StatefulWidget {
  const _SalaryDetailForm({super.key});

  @override
  State<_SalaryDetailForm> createState() => _SalaryDetailFormState();
}

class _SalaryDetailFormState extends State<_SalaryDetailForm> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late double _hours;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    // Load the initial values from the ViewModel (initialPayroll)
    final model = context.read<SalaryDetailViewModel>().initialPayroll;
    _amount = model.amount;
    _hours = model.hoursWorked;
    _paymentMethod = model.paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SalaryDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Process Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (viewModel.error != null)
                Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(labelText: 'Amount (RM)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
                onChanged: (value) => _amount = double.parse(value),
              ),
              TextFormField(
                initialValue: _hours.toString(),
                decoration: const InputDecoration(labelText: 'Hours Worked'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter hours';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
                onChanged: (value) => _hours = double.parse(value),
              ),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['DuitNow', 'IPay88'].map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),
              const SizedBox(height: 20),
              viewModel.isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _confirmPayment(context, viewModel),
                      child: const Text('Process Payment'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPayment(BuildContext context, SalaryDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: const Text('Are you sure you want to process this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.processPayment(
                _amount,
                _hours,
                _paymentMethod,
              );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful!')),
                );
                Navigator.pop(context); // Return to previous screen
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.error ?? 'Payment failed')),
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
