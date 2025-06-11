// lib/viewmodels/manage_schedule/create_schedule_view_model.dart
import 'package:flutter/foundation.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';

class CreateScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository;
  final String workshopId;

  CreateScheduleViewModel({
    required ScheduleRepository scheduleRepository,
    required this.workshopId,
  }) : _scheduleRepository = scheduleRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Create schedule method
  Future<void> createSchedule({
    required DateTime scheduleDate,
    required DateTime startTime,
    required DateTime endTime,
    required DayType dayType,
    required int maxForeman,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      // Validation
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }

      if (scheduleDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        throw Exception('Cannot schedule for past dates');
      }

      final schedule = Schedule(
        scheduleId: '', // Will be set by Firestore
        workshopId: workshopId,
        scheduleDate: scheduleDate,
        startTime: startTime,
        endTime: endTime,
        dayType: dayType,
        maxForeman: maxForeman,
        availableSlots: maxForeman,
        foremanIds: [],
        status: ScheduleStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _scheduleRepository.createSchedule(schedule);
      _successMessage = 'Schedule created successfully';
      
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() => _clearMessages();
}