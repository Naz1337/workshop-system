// lib/viewmodels/manage_schedule/slot_selection_view_model.dart
import 'package:flutter/foundation.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';

enum SlotSelectionErrorType {
  slotFull,
  doubleBooking,
  oneSlotPerDay,
  generic,
}

class SlotSelectionViewModel extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository;
  final String foremanId;

  SlotSelectionViewModel({
    required ScheduleRepository scheduleRepository,
    required this.foremanId,
  }) : _scheduleRepository = scheduleRepository;

  List<Schedule> _availableSchedules = [];
  bool _isLoading = false;
  bool _isBooking = false;
  String? _errorMessage;
  String? _successMessage;
  SlotSelectionErrorType? _errorType;

  // Getters
  List<Schedule> get availableSchedules => _availableSchedules;
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  SlotSelectionErrorType? get errorType => _errorType;

  // Initialize stream
  void initialize() {
    _setLoading(true);
    _scheduleRepository.getAvailableSchedules().listen(
      (schedules) {
        _availableSchedules = schedules;
        _setLoading(false);
      },
      onError: (error) {
        _setError(error.toString(), SlotSelectionErrorType.generic);
        _setLoading(false);
      },
    );
  }

  // Enhanced booking with SRS error handling
  Future<void> bookSlot(String scheduleId) async {
    _setBooking(true);
    _clearMessages();

    try {
      await _scheduleRepository.bookSlot(scheduleId, foremanId);
      _successMessage = 'Slot booked successfully';
      notifyListeners();
    } on DoubleBookingException catch (e) {
      // SRS E2: Double Booking Exception Flow
      _setError(e.toString(), SlotSelectionErrorType.doubleBooking);
    } on OneSlotPerDayException catch (e) {
      // SRS Business Rule: One slot per day
      _setError(e.toString(), SlotSelectionErrorType.oneSlotPerDay);
    } on SlotFullException catch (e) {
      // SRS E1: Slot Full Exception Flow
      _setError(e.toString(), SlotSelectionErrorType.slotFull);
    } catch (e) {
      _setError(e.toString(), SlotSelectionErrorType.generic);
    } finally {
      _setBooking(false);
    }
  }

  // Check availability before booking - Enhanced with SRS rules
  bool checkAvailability(Schedule schedule) {
    // SRS Rule: Check if slot is available
    if (schedule.status != ScheduleStatus.available) return false;
    
    // SRS Rule: Check if slot has available capacity
    if (schedule.availableSlots <= 0) return false;
    
    // SRS Rule: Check if foreman already booked this slot (prevents double booking)
    if (schedule.isForemanAlreadyBooked(foremanId)) return false;
    
    // SRS Rule: Check if slot is full (max 3 foremen)
    if (schedule.isSlotFull()) return false;
    
    return true;
  }

  // SRS E1 Flow: Get alternative slots when slot is full
  Future<List<Schedule>> getAlternativeSlots(DateTime excludeDate) async {
    try {
      return await _scheduleRepository.getAlternativeSlots(excludeDate);
    } catch (e) {
      return [];
    }
  }

  // Enhanced validation for SRS business rules
  Future<bool> canBookSlot(Schedule schedule) async {
    try {
      // Basic availability check
      if (!checkAvailability(schedule)) return false;
      
      // SRS Rule: Check if foreman already has booking on same date
      final hasBookingOnDate = await _scheduleRepository.hasBookingOnDate(
        foremanId, 
        schedule.scheduleDate
      );
      
      return !hasBookingOnDate;
    } catch (e) {
      return false;
    }
  }

  // Filter schedules by date for calendar view
  List<Schedule> getSchedulesForDate(DateTime date) {
    return _availableSchedules.where((schedule) {
      return schedule.scheduleDate.year == date.year &&
             schedule.scheduleDate.month == date.month &&
             schedule.scheduleDate.day == date.day;
    }).toList();
  }

  // Get schedules by day type
  List<Schedule> getSchedulesByDayType(DayType dayType, DateTime date) {
    return getSchedulesForDate(date)
        .where((schedule) => schedule.dayType == dayType)
        .toList();
  }

  // Check if foreman has any bookings (for UI state management)
  Future<bool> hasAnyBookings() async {
    try {
      // This would typically be handled by another stream or method
      // For now, we'll return false and let the actual check happen during booking
      return false;
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setBooking(bool booking) {
    _isBooking = booking;
    notifyListeners();
  }

  void _setError(String message, SlotSelectionErrorType type) {
    _errorMessage = message;
    _errorType = type;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _errorType = null;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}