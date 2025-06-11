// lib/views/manage_schedule/schedule_overview_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../viewmodels/manage_schedule/schedule_overview_view_model.dart';

class ScheduleOverviewPage extends StatefulWidget {
  final String workshopId;
  
  const ScheduleOverviewPage({super.key, required this.workshopId});

  @override
  State<ScheduleOverviewPage> createState() => _ScheduleOverviewPageState();
}

class _ScheduleOverviewPageState extends State<ScheduleOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScheduleOverviewViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        workshopId: widget.workshopId,
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule Overview'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/create-schedule/${widget.workshopId}'),
            ),
          ],
        ),
        body: Consumer<ScheduleOverviewViewModel>(
          builder: (context, viewModel, child) {
            // Show error message
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                viewModel.clearError();
              });
            }

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.schedules.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No schedules created yet'),
                    SizedBox(height: 8),
                    Text('Tap the + button to create your first schedule'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.schedules.length,
              itemBuilder: (context, index) {
                final schedule = viewModel.schedules[index];
                return _ScheduleCard(
                  schedule: schedule,
                  onStatusChanged: (status) => viewModel.updateScheduleStatus(schedule.scheduleId, status),
                  onDelete: () => _confirmDelete(context, viewModel, schedule),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ScheduleOverviewViewModel viewModel, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deleteSchedule(schedule.scheduleId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final Function(ScheduleStatus) onStatusChanged;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onStatusChanged,
    required this.onDelete,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${schedule.scheduleDate.day}/${schedule.scheduleDate.month}/${schedule.scheduleDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}'),
            Text('Day Type: ${schedule.dayType.toString().split('.').last.toUpperCase()}'),
            Text('Slots: ${schedule.availableSlots}/${schedule.maxForeman} available'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(schedule.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (schedule.status == ScheduleStatus.available)
                  DropdownButton<ScheduleStatus>(
                    value: schedule.status,
                    items: ScheduleStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (status) {
                      if (status != null) onStatusChanged(status);
                    },
                  ),
              ],
            ),
            if (schedule.foremanIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Booked by: ${schedule.foremanIds.length} foremen'),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.available:
        return Colors.green;
      case ScheduleStatus.full:
        return Colors.orange;
      case ScheduleStatus.cancelled:
        return Colors.red;
    }
  }
}