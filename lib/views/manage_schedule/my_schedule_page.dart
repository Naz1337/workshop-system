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

class _MySchedulePageState extends State<MySchedulePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyScheduleViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        foremanId: widget.foremanId,
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MY SCHEDULE'), // Match SRS Figure 3.19
          centerTitle: true,
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

            return Column(
              children: [
                // Header matching SRS Figure 3.19
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Scheduled',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Schedule List
                Expanded(
                  child: _buildScheduleList(viewModel),
                ),
                
                // Back Button - Match SRS UI
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleList(MyScheduleViewModel viewModel) {
    final allSchedules = viewModel.mySchedules;
    
    if (allSchedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No schedules found'),
            SizedBox(height: 8),
            Text('Book your first slot to see it here'),
          ],
        ),
      );
    }

    // Group schedules by upcoming and past
    final now = DateTime.now();
    final upcomingSchedules = allSchedules
        .where((schedule) => schedule.scheduleDate.isAfter(now))
        .toList();
    final pastSchedules = allSchedules
        .where((schedule) => schedule.scheduleDate.isBefore(now))
        .toList();

    return ListView(
      children: [
        // Upcoming Schedules Section
        if (upcomingSchedules.isNotEmpty) ...[
          _buildSectionHeader('Upcoming Schedules'),
          ...upcomingSchedules.map((schedule) => _MyScheduleRow(
            schedule: schedule,
            showCancelButton: viewModel.canCancelBooking(schedule),
            isCancelling: viewModel.isCancelling,
            onCancel: () => _confirmCancel(context, viewModel, schedule),
          )),
        ],
        
        // Past Schedules Section
        if (pastSchedules.isNotEmpty) ...[
          _buildSectionHeader('Past Schedules'),
          ...pastSchedules.map((schedule) => _MyScheduleRow(
            schedule: schedule,
            showCancelButton: false,
            isCancelling: false,
            onCancel: () {},
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, MyScheduleViewModel viewModel, Schedule schedule) {
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
              viewModel.cancelBooking(schedule.scheduleId);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MyScheduleRow extends StatelessWidget {
  final Schedule schedule;
  final bool showCancelButton;
  final bool isCancelling;
  final VoidCallback onCancel;

  const _MyScheduleRow({
    required this.schedule,
    required this.showCancelButton,
    required this.isCancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Date Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDayName(schedule.scheduleDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${schedule.scheduleDate.day}/${schedule.scheduleDate.month}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Scheduled Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  schedule.dayType.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Details/Action Column
          Expanded(
            flex: 1,
            child: showCancelButton
                ? ElevatedButton(
                    onPressed: isCancelling ? null : onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(60, 32),
                    ),
                    child: isCancelling
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Cancel', style: TextStyle(fontSize: 12)),
                  )
                : const Text(
                    'Completed',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}