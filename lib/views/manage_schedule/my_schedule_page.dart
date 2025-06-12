// lib/views/manage_schedule/my_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
          title: const Text('MY SCHEDULE'), 
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/select-slot/${widget.foremanId}'),
              tooltip: 'Book New Slot',
            ),
          ],
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
                
                _buildBottomNavigationBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/select-slot/${widget.foremanId}'),
                  icon: const Icon(Icons.add),
                  label: const Text('Book New Slot'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(MyScheduleViewModel viewModel) {
    final allSchedules = viewModel.mySchedules;
    
    if (allSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No schedules found'),
            const SizedBox(height: 8),
            const Text('Book your first slot to see it here'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/select-slot/${widget.foremanId}'),
              icon: const Icon(Icons.add),
              label: const Text('Book Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
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
          _buildSectionHeader('Upcoming Schedules (${upcomingSchedules.length})'),
          ...upcomingSchedules.map((schedule) => _MyScheduleRow(
            schedule: schedule,
            showCancelButton: viewModel.canCancelBooking(schedule),
            isCancelling: viewModel.isCancelling,
            onCancel: () => _confirmCancel(context, viewModel, schedule),
          )),
        ],
        
        // Past Schedules Section
        if (pastSchedules.isNotEmpty) ...[
          _buildSectionHeader('Past Schedules (${pastSchedules.length})'),
          ...pastSchedules.map((schedule) => _MyScheduleRow(
            schedule: schedule,
            showCancelButton: false,
            isCancelling: false,
            onCancel: () {},
          )),
        ],
        
        // If no upcoming schedules, show prompt to book
        if (upcomingSchedules.isEmpty && pastSchedules.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                const Text(
                  'No upcoming schedules',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Would you like to book a new slot?'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.push('/select-slot/${widget.foremanId}'),
                  child: const Text('Book New Slot'),
                ),
              ],
            ),
          ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 8),
            Text(
              '${schedule.dayType.toString().split('.').last} slot on ${schedule.scheduleDate.day}/${schedule.scheduleDate.month}/${schedule.scheduleDate.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
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
    final isUpcoming = schedule.scheduleDate.isAfter(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
        color: isUpcoming ? null : Colors.grey[50],
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
                  style: TextStyle(
                    fontSize: 12, 
                    color: isUpcoming ? Colors.grey : Colors.grey[400],
                  ),
                ),
                Text(
                  '${schedule.scheduleDate.day}/${schedule.scheduleDate.month}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.black : Colors.grey[600],
                  ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.black : Colors.grey[600],
                  ),
                ),
                Text(
                  schedule.dayType.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12, 
                    color: isUpcoming ? Colors.grey : Colors.grey[400],
                  ),
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
                : Text(
                    isUpcoming ? 'Confirmed' : 'Completed',
                    style: TextStyle(
                      fontSize: 12, 
                      color: isUpcoming ? Colors.green : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
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