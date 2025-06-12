// lib/viewmodels/manage_schedule/create_schedule_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> createSchedule({
    required DateTime scheduleDate,
    required DateTime startTime,
    required DateTime endTime,
    required DayType dayType,
    required int maxForeman, // Will be ignored, always set to 3
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _validateScheduleInput(scheduleDate, startTime, endTime, dayType);

      final schedule = Schedule(
        scheduleId: '', // Will be set by Firestore
        workshopId: workshopId,
        scheduleDate: scheduleDate,
        startTime: startTime,
        endTime: endTime,
        dayType: dayType,
        maxForeman: 3, // SRS Rule: Fixed at 3 foremen per slot
        availableSlots: 3, // SRS Rule: Initially 3 available slots
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

  Future<void> _validateScheduleInput(
    DateTime scheduleDate,
    DateTime startTime,
    DateTime endTime,
    DayType dayType,
  ) async {
    // Basic time validation
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
    );

    if (scheduleDay.isBefore(today)) {
      throw Exception('Cannot schedule for past dates');
    }

    final duration = endTime.difference(startTime);
    if (duration.inMinutes < 60) {
      throw Exception('Schedule must be at least 1 hour long');
    }

    await _checkScheduleConflicts(scheduleDate, startTime, endTime, dayType);

    _validateTimeSlotForDayType(dayType, startTime, endTime);

    _validateAdvanceBooking(scheduleDate);
  }

  Future<void> _checkScheduleConflicts(
    DateTime scheduleDate,
    DateTime startTime,
    DateTime endTime,
    DayType dayType,
  ) async {
    await _validateDailyLimits(scheduleDate, dayType);

    if (!_isWithinOperatingHours(startTime) ||
        !_isWithinOperatingHours(endTime)) {
      throw Exception('Schedule must be within operating hours (6 AM - 10 PM)');
    }
  }

  void _validateTimeSlotForDayType(
    DayType dayType,
    DateTime startTime,
    DateTime endTime,
  ) {
    switch (dayType) {
      case DayType.morning:
        if (startTime.hour < 6 || startTime.hour >= 12) {
          throw Exception(
            'Morning slots should start between 6:00 AM and 12:00 PM',
          );
        }
        if (endTime.hour > 12) {
          throw Exception('Morning slots should end by 12:00 PM');
        }
        break;

      case DayType.afternoon:
        if (startTime.hour < 12 || startTime.hour >= 17) {
          throw Exception(
            'Afternoon slots should start between 12:00 PM and 5:00 PM',
          );
        }
        if (endTime.hour > 17) {
          throw Exception('Afternoon slots should end by 5:00 PM');
        }
        break;

      case DayType.evening:
        if (startTime.hour < 17 || startTime.hour >= 22) {
          throw Exception(
            'Evening slots should start between 5:00 PM and 10:00 PM',
          );
        }
        if (endTime.hour > 22) {
          throw Exception('Evening slots should end by 10:00 PM');
        }
        break;
    }
  }

  bool _isWithinOperatingHours(DateTime time) {
    // Example business hours: 6 AM to 10 PM
    return time.hour >= 6 && time.hour <= 22;
  }

  Map<String, TimeOfDay> getSuggestedTimes(DayType dayType) {
    switch (dayType) {
      case DayType.morning:
        return {
          'start': const TimeOfDay(hour: 8, minute: 0),
          'end': const TimeOfDay(hour: 12, minute: 0),
        };
      case DayType.afternoon:
        return {
          'start': const TimeOfDay(hour: 12, minute: 0),
          'end': const TimeOfDay(hour: 17, minute: 0),
        };
      case DayType.evening:
        return {
          'start': const TimeOfDay(hour: 17, minute: 0),
          'end': const TimeOfDay(hour: 21, minute: 0),
        };
    }
  }

  String getDayTypeDisplayText(DayType dayType) {
    switch (dayType) {
      case DayType.morning:
        return 'Morning (6:00 AM - 12:00 PM)';
      case DayType.afternoon:
        return 'Afternoon (12:00 PM - 5:00 PM)';
      case DayType.evening:
        return 'Evening (5:00 PM - 10:00 PM)';
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

  Future<List<Schedule>> _getExistingSchedules(DateTime date) async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _validateDailyLimits(
    DateTime scheduleDate,
    DayType dayType,
  ) async {
    final existingSchedules = await _getExistingSchedules(scheduleDate);
    final sameTypeSlots =
        existingSchedules.where((s) => s.dayType == dayType).length;

    if (sameTypeSlots >= 2) {
      throw Exception(
        'Maximum 2 ${dayType.toString().split('.').last} slots allowed per day',
      );
    }
  }

  DateTime getRecommendedStartTime(DateTime date, DayType dayType) {
    switch (dayType) {
      case DayType.morning:
        return DateTime(date.year, date.month, date.day, 8, 0);
      case DayType.afternoon:
        return DateTime(date.year, date.month, date.day, 13, 0);
      case DayType.evening:
        return DateTime(date.year, date.month, date.day, 18, 0);
    }
  }

  DateTime getRecommendedEndTime(DateTime date, DayType dayType) {
    switch (dayType) {
      case DayType.morning:
        return DateTime(date.year, date.month, date.day, 12, 0);
      case DayType.afternoon:
        return DateTime(date.year, date.month, date.day, 17, 0);
      case DayType.evening:
        return DateTime(date.year, date.month, date.day, 22, 0);
    }
  }

  void updateTimesForDayType(
    DayType newDayType,
    DateTime selectedDate,
    Function(DateTime, DateTime) onTimesUpdated,
  ) {
    final newStartTime = getRecommendedStartTime(selectedDate, newDayType);
    final newEndTime = getRecommendedEndTime(selectedDate, newDayType);
    onTimesUpdated(newStartTime, newEndTime);
  }

  void _validateAdvanceBooking(DateTime scheduleDate) {
    final now = DateTime.now();
    final difference = scheduleDate.difference(now);

    if (difference.inHours < 2) {
      throw Exception('Schedule must be created at least 2 hours in advance');
    }
  }

  Map<String, bool> getValidationSummary(
    DateTime scheduleDate,
    DateTime startTime,
    DateTime endTime,
    DayType dayType,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
    );

    return {
      'validDate': !scheduleDay.isBefore(today),
      'validTimeOrder': startTime.isBefore(endTime),
      'validDuration': endTime.difference(startTime).inMinutes >= 60,
      'validDayType': _isTimeValidForDayType(dayType, startTime, endTime),
      'validAdvance': scheduleDate.difference(now).inHours >= 2,
    };
  }

  bool _isTimeValidForDayType(
    DayType dayType,
    DateTime startTime,
    DateTime endTime,
  ) {
    switch (dayType) {
      case DayType.morning:
        return startTime.hour >= 6 && startTime.hour < 12 && endTime.hour <= 12;
      case DayType.afternoon:
        return startTime.hour >= 12 &&
            startTime.hour < 17 &&
            endTime.hour <= 17;
      case DayType.evening:
        return startTime.hour >= 17 &&
            startTime.hour < 22 &&
            endTime.hour <= 22;
    }
  }

  String formatDuration(DateTime startTime, DateTime endTime) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
