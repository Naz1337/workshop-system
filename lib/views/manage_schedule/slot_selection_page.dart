// lib/views/manage_schedule/slot_selection_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../viewmodels/manage_schedule/slot_selection_view_model.dart';

class SlotSelectionPage extends StatefulWidget {
  final String foremanId;
  
  const SlotSelectionPage({super.key, required this.foremanId});

  @override
  State<SlotSelectionPage> createState() => _SlotSelectionPageState();
}

class _SlotSelectionPageState extends State<SlotSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SlotSelectionViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        foremanId: widget.foremanId,
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Available Slots'),
        ),
        body: Consumer<SlotSelectionViewModel>(
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

            if (viewModel.availableSchedules.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No available slots'),
                    SizedBox(height: 8),
                    Text('Check back later for new opportunities'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.availableSchedules.length,
              itemBuilder: (context, index) {
                final schedule = viewModel.availableSchedules[index];
                return _SlotCard(
                  schedule: schedule,
                  isBooking: viewModel.isBooking,
                  canBook: viewModel.checkAvailability(schedule),
                  onBook: () => viewModel.bookSlot(schedule.scheduleId),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final Schedule schedule;
  final bool isBooking;
  final bool canBook;
  final VoidCallback onBook;

  const _SlotCard({
    required this.schedule,
    required this.isBooking,
    required this.canBook,
    required this.onBook,
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
            Text('Available Slots: ${schedule.availableSlots}/${schedule.maxForeman}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (canBook && !isBooking) ? onBook : null,
                child: isBooking
                    ? const CircularProgressIndicator()
                    : Text(canBook ? 'Book Slot' : 'Not Available'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}