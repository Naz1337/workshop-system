// lib/views/manage_schedule/my_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../viewmodels/manage_schedule/my_schedule_view_model.dart';

class MySchedulePage extends StatefulWidget {
  final String foremanId;
  
  const MySchedulePage({super.key, required this.foremanId});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyScheduleViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        foremanId: widget.foremanId,
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Schedule'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: Consumer<MyScheduleViewModel>(
          builder: (context, viewModel, child) {
            // Show messages
            if (viewModel.successMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.successMessage!),
                    backgroundColor: Colors.green,
                  ),
                );
                viewModel.clearMessages();
              });
            }

            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                viewModel.clearMessages();
              });
            }

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _ScheduleList(
                  schedules: viewModel.upcomingSchedules,
                  isUpcoming: true,
                  isCancelling: viewModel.isCancelling,
                  canCancel: viewModel.canCancelBooking,
                  onCancel: viewModel.cancelBooking,
                ),
                _ScheduleList(
                  schedules: viewModel.pastSchedules,
                  isUpcoming: false,
                  isCancelling: false,
                  canCancel: (_) => false,
                  onCancel: (_) {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  final bool isUpcoming;
  final bool isCancelling;
  final bool Function(Schedule) canCancel;
  final Function(String) onCancel;

  const _ScheduleList({
    required this.schedules,
    required this.isUpcoming,
    required this.isCancelling,
    required this.canCancel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event : Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(isUpcoming ? 'No upcoming schedules' : 'No past schedules'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _MyScheduleCard(
          schedule: schedule,
          showCancelButton: isUpcoming && canCancel(schedule),
          isCancelling: isCancelling,
          onCancel: () => _confirmCancel(context, schedule),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel(schedule.scheduleId);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MyScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool showCancelButton;
  final bool isCancelling;
  final VoidCallback onCancel;

  const _MyScheduleCard({
    required this.schedule,
    required this.showCancelButton,
    required this.isCancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${schedule.scheduleDate.day}/${schedule.scheduleDate.month}/${schedule.scheduleDate.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}'),
            Text('Day Type: ${schedule.dayType.toString().split('.').last.toUpperCase()}'),
            Text('Other Foremen: ${schedule.foremanIds.length - 1}'),
            if (showCancelButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCancelling ? null : onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isCancelling
                      ? const CircularProgressIndicator()
                      : const Text('Cancel Booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}