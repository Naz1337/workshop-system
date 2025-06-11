// lib/views/manage_schedule/slot_selection_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../viewmodels/manage_schedule/slot_selection_view_model.dart';

class SlotSelectionPage extends StatefulWidget {
  final String foremanId;
  
  const SlotSelectionPage({super.key, required this.foremanId});

  @override
  State<SlotSelectionPage> createState() => _SlotSelectionPageState();
}

class _SlotSelectionPageState extends State<SlotSelectionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

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
      create: (context) => SlotSelectionViewModel(
        scheduleRepository: Provider.of<ScheduleRepository>(context, listen: false),
        foremanId: widget.foremanId,
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'), // Match SRS UI Figure 3.14
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'),
            ],
          ),
        ),
        body: Consumer<SlotSelectionViewModel>(
          builder: (context, viewModel, child) {
            // Handle success messages - SRS Figure 3.16
            if (viewModel.successMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showSuccessDialog(context, viewModel.successMessage!);
              });
            }

            // Handle SRS Exception Flows
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.errorType == SlotSelectionErrorType.slotFull) {
                  _showSlotFullDialog(context, viewModel); // SRS E1 Flow
                } else if (viewModel.errorType == SlotSelectionErrorType.doubleBooking) {
                  _showDoubleBookingDialog(context); // SRS E2 Flow
                } else if (viewModel.errorType == SlotSelectionErrorType.oneSlotPerDay) {
                  _showOneSlotPerDayDialog(context);
                } else {
                  _showGenericErrorDialog(context, viewModel.errorMessage!);
                }
                viewModel.clearMessages();
              });
            }

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Calendar Widget - Match SRS UI Figure 3.14
                _buildCalendarHeader(),
                _buildCalendarGrid(),
                const SizedBox(height: 16),
                
                // Available Slots List
                Expanded(
                  child: _buildSlotsList(viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
              });
            },
          ),
          Text(
            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    
    List<Widget> dayWidgets = [];
    
    // Empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }
    
    // Days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final isToday = _isSameDay(date, DateTime.now());
      final isSelected = _isSameDay(date, _selectedDate);
      
      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : (isToday ? Colors.blue.withOpacity(0.3) : null),
                borderRadius: BorderRadius.circular(20),
                border: isToday ? Border.all(color: Colors.blue) : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Build rows of 7 days each
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          children: dayWidgets.sublist(i, (i + 7).clamp(0, dayWidgets.length)),
        ),
      );
    }
    
    return Column(children: rows);
  }

  Widget _buildSlotsList(SlotSelectionViewModel viewModel) {
    final filteredSchedules = viewModel.availableSchedules
        .where((schedule) => _isSameDay(schedule.scheduleDate, _selectedDate))
        .toList();

    if (filteredSchedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No available slots for this date'),
            SizedBox(height: 8),
            Text('Please select another date'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Morning Slots
        _buildSlotSection('Morning Slot', filteredSchedules
            .where((s) => s.dayType == DayType.morning)
            .toList(), viewModel),
        
        // Afternoon Slots  
        _buildSlotSection('Afternoon Slot', filteredSchedules
            .where((s) => s.dayType == DayType.afternoon)
            .toList(), viewModel),
            
        // Evening Slots
        _buildSlotSection('Evening Slot', filteredSchedules
            .where((s) => s.dayType == DayType.evening)
            .toList(), viewModel),
      ],
    );
  }

  Widget _buildSlotSection(String title, List<Schedule> schedules, SlotSelectionViewModel viewModel) {
    if (schedules.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...schedules.map((schedule) => _SlotCard(
          schedule: schedule,
          isBooking: viewModel.isBooking,
          canBook: viewModel.checkAvailability(schedule),
          onBook: () => viewModel.bookSlot(schedule.scheduleId),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  // SRS Success Dialog - Figure 3.16
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
              'Saved Successfully',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Go to "My Schedule" to check your booking'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/my-schedule/${widget.foremanId}');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // SRS E1: Slot Full Dialog - Figure 3.15
  void _showSlotFullDialog(BuildContext context, SlotSelectionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Slot Full',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Please select another slot!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // SRS: System displays available slots (E1 flow)
              _showAlternativeSlots(context, viewModel);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // SRS E2: Double Booking Dialog - Figure 3.17
  void _showDoubleBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Select a double booking. Please go check "My Schedule" page.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // SRS E2: Redirect to "My Schedule" page
              context.push('/my-schedule/${widget.foremanId}');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showOneSlotPerDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Limit Reached'),
        content: const Text('You can only book one slot per day. Please choose a different date.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGenericErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // SRS E1: Show alternative available slots
  void _showAlternativeSlots(BuildContext context, SlotSelectionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alternative Available Slots'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FutureBuilder<List<Schedule>>(
            future: viewModel.getAlternativeSlots(_selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No alternative slots available'));
              }
              
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final schedule = snapshot.data![index];
                  return ListTile(
                    title: Text('${schedule.scheduleDate.day}/${schedule.scheduleDate.month}/${schedule.scheduleDate.year}'),
                    subtitle: Text('${schedule.dayType.toString().split('.').last} - ${schedule.availableSlots} slots available'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedDate = schedule.scheduleDate;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${schedule.dayType.toString().split('.').last} Slot (${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${schedule.availableSlots} SLOTS AVAILABLE'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: (canBook && !isBooking) ? onBook : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canBook ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: isBooking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(canBook ? 'Book' : 'Full'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}