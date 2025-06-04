// File: lib/views/pending_payroll_page.dart
import 'package:flutter/material.dart';
import '../../../model/payroll.dart';
import '../../../controller/payroll_controller.dart';
import 'salary_detail_page.dart';

class PendingPayrollPage extends StatefulWidget {
  const PendingPayrollPage({super.key});

  @override
  _PendingPayrollPageState createState() => _PendingPayrollPageState();
}

class _PendingPayrollPageState extends State<PendingPayrollPage> {
  final controller = PayrollController();
  late Future<List<Payroll>> payrolls;

  @override
  void initState() {
    super.initState();
    payrolls = controller.fetchPendingPayrolls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Payrolls')),
      body: FutureBuilder<List<Payroll>>(
        future: payrolls,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending payrolls.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final payroll = items[index];
              return ListTile(
                title: Text(payroll.foremanName),
                subtitle: Text('RM ${payroll.salary.toStringAsFixed(2)}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SalaryDetailPage(payroll: payroll),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}