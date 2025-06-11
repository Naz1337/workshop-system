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
  int _maxForeman = 3;

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
          title: const Text('Create Schedule'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.successMessage!),
                    backgroundColor: Colors.green,
                  ),
                );
                viewModel.clearMessages();
                context.pop();
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
                        title: const Text('Schedule Date'),
                        subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Selection
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: ListTile(
                              title: const Text('Start Time'),
                              subtitle: Text(_startTime.format(context)),
                              trailing: const Icon(Icons.access_time),
                              onTap: () => _selectStartTime(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              title: const Text('End Time'),
                              subtitle: Text(_endTime.format(context)),
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
                            const Text('Day Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            RadioListTile<DayType>(
                              title: const Text('Morning'),
                              value: DayType.morning,
                              groupValue: _dayType,
                              onChanged: (value) => setState(() => _dayType = value!),
                            ),
                            RadioListTile<DayType>(
                              title: const Text('Afternoon'),
                              value: DayType.afternoon,
                              groupValue: _dayType,
                              onChanged: (value) => setState(() => _dayType = value!),
                            ),
                            RadioListTile<DayType>(
                              title: const Text('Evening'),
                              value: DayType.evening,
                              groupValue: _dayType,
                              onChanged: (value) => setState(() => _dayType = value!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Max Foreman Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Maximum Foremen: $_maxForeman', 
                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Slider(
                              value: _maxForeman.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: _maxForeman.toString(),
                              onChanged: (value) => setState(() => _maxForeman = value.toInt()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Button
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : () => _createSchedule(viewModel),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Create Schedule', style: TextStyle(fontSize: 16)),
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
        maxForeman: _maxForeman,
      );
    }
  }
}