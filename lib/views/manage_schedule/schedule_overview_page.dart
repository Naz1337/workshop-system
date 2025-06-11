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

class _ScheduleOverviewPageState extends State<ScheduleOverviewPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScheduleOverviewViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        workshopId: widget.workshopId,
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SCHEDULE'), // Match SRS Figure 3.11
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/create-schedule/${widget.workshopId}'),
              tooltip: 'Add Slot', // Match SRS UI
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'), // Match SRS UI Figure 3.11
            ],
          ),
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

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTodaySchedules(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodaySchedules(ScheduleOverviewViewModel viewModel) {
    // Filter schedules for today and upcoming days
    final now = DateTime.now();
    final todaySchedules = viewModel.schedules.where((schedule) {
      return schedule.scheduleDate.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();

    // Sort by date
    todaySchedules.sort((a, b) => a.scheduleDate.compareTo(b.scheduleDate));

    if (todaySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No schedules available'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.push('/create-schedule/${widget.workshopId}'),
              icon: const Icon(Icons.add),
              label: const Text('Add Slot'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaySchedules.length,
      itemBuilder: (context, index) {
        final schedule = todaySchedules[index];
        return _ScheduleCard(
          schedule: schedule,
          onStatusChanged: (status) => viewModel.updateScheduleStatus(schedule.scheduleId, status),
          onDelete: () => _confirmDelete(context, viewModel, schedule),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ScheduleOverviewViewModel viewModel, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete the ${schedule.dayType.toString().split('.').last} slot on ${schedule.scheduleDate.day}/${schedule.scheduleDate.month}/${schedule.scheduleDate.year}?'),
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
      child: Column(
        children: [
          // Foreman List - Match SRS Figure 3.11 layout
          if (schedule.foremanIds.isNotEmpty) ...[
            ...schedule.foremanIds.asMap().entries.map((entry) {
              final index = entry.key;
              final foremanId = entry.value;
              return _ForemanRow(
                initial: String.fromCharCode(65 + index), // A, B, C, etc.
                name: 'Foreman ${foremanId.substring(0, 8)}', // Truncated ID for display
                slot: '${schedule.dayType.toString().split('.').last} Slot',
                time: '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                status: 'Confirmed', // Match SRS UI
              );
            }),
          ] else ...[
            // Empty slot display
            _ForemanRow(
              initial: '',
              name: 'No bookings yet',
              slot: '${schedule.dayType.toString().split('.').last} Slot',
              time: '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
              status: 'Available',
            ),
          ],
          
          // Schedule Info Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedule.scheduleDate.day}/${schedule.scheduleDate.month}/${schedule.scheduleDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Slots: ${schedule.availableSlots}/3 available',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(schedule.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.status.toString().split('.').last.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

class _ForemanRow extends StatelessWidget {
  final String initial;
  final String name;
  final String slot;
  final String time;
  final String status;

  const _ForemanRow({
    required this.initial,
    required this.name,
    required this.slot,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Initial Circle - Match SRS UI Figure 3.11
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: initial.isEmpty ? Colors.grey[300] : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$slot • $time',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Status Badge - Match SRS UI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Confirmed' ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}