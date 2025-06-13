// lib/views/manage_schedule/create_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../viewmodels/manage_schedule/create_schedule_view_model.dart';

class CreateSchedulePage extends StatefulWidget {
  final String workshopId;
  
  const CreateSchedulePage({super.key, required this.workshopId});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  DayType _dayType = DayType.morning;
  static const int _maxForeman = 3;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 17, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateScheduleViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        workshopId: widget.workshopId,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Slot'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Consumer<CreateScheduleViewModel>(
          builder: (context, viewModel, child) {
            // Show success message and navigate back
            if (viewModel.successMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showSuccessDialog(context, viewModel.successMessage!);
              });
            }

            // Show error message
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Selection
                    Card(
                      child: ListTile(
                        title: const Text('Date'),
                        subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: ListTile(
                              title: const Text('Start'),
                              subtitle: Text(_formatTime(_startTime)),
                              trailing: const Icon(Icons.access_time),
                              onTap: () => _selectStartTime(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              title: const Text('End'),
                              subtitle: Text(_formatTime(_endTime)),
                              trailing: const Icon(Icons.access_time),
                              onTap: () => _selectEndTime(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Day Type Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Session Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            DropdownButtonFormField<DayType>(
                              value: _dayType,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: DayType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toString().split('.').last.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _dayType = value!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fixed Foreman Count Display - SRS Rule: Always 3
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Maximum Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$_maxForeman foremen (Fixed)', 
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Each slot allows maximum 3 foremen as per system rule',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : () => _createSchedule(viewModel),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save', style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 8),

                    // Cancel Button
                    TextButton(
                      onPressed: viewModel.isLoading ? null : () => context.pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  void _createSchedule(CreateScheduleViewModel viewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      
      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      viewModel.createSchedule(
        scheduleDate: _selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        dayType: _dayType,
        maxForeman: _maxForeman, // Always 3 as per SRS
      );
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Data Successfully Saved',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('New slot was added to the system'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}