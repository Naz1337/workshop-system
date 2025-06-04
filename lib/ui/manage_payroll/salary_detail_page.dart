import 'package:flutter/material.dart';
import '../../../model/payroll.dart';
import '../../../controller/payroll_controller.dart';

class SalaryDetailPage extends StatefulWidget {
  final Payroll payroll;
  const SalaryDetailPage({super.key, required this.payroll});

  @override
  _SalaryDetailPageState createState() => _SalaryDetailPageState();
}

class _SalaryDetailPageState extends State<SalaryDetailPage> {
  final controller = PayrollController();
  String selectedMethod = 'DuitNow';
  bool isProcessing = false;

  void handlePayment() async {
    setState(() => isProcessing = true);
    try {
      await controller.confirmPayment(widget.payroll, selectedMethod);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salary Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foreman: ${widget.payroll.foremanName}'),
            Text('Salary: RM ${widget.payroll.salary.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Text('Select Payment Method:'),
            DropdownButton<String>(
              value: selectedMethod,
              onChanged: (value) => setState(() => selectedMethod = value!),
              items: ['DuitNow', 'iPay88']
                .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ))
                .toList(),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isProcessing ? null : handlePayment,
                  child: Text('Confirm Payment'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Cancel'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}