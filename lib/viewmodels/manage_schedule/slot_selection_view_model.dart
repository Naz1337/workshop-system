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

  List<Schedule> get availableSchedules => _availableSchedules;
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  SlotSelectionErrorType? get errorType => _errorType;

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

  Future<void> bookSlot(String scheduleId) async {
    _setBooking(true);
    _clearMessages();

    try {
      await _scheduleRepository.bookSlot(scheduleId, foremanId);
      _successMessage = 'Slot booked successfully';
      notifyListeners();
    } on DoubleBookingException catch (e) {
      _setError(e.toString(), SlotSelectionErrorType.doubleBooking);
    } on OneSlotPerDayException catch (e) {
      _setError(e.toString(), SlotSelectionErrorType.oneSlotPerDay);
    } on SlotFullException catch (e) {
      _setError(e.toString(), SlotSelectionErrorType.slotFull);
    } catch (e) {
      _setError(e.toString(), SlotSelectionErrorType.generic);
    } finally {
      _setBooking(false);
    }
  }

  // Check availability before booking
  bool checkAvailability(Schedule schedule) {
    if (schedule.status != ScheduleStatus.available) return false;
    
    if (schedule.availableSlots <= 0) return false;
    
    if (schedule.isForemanAlreadyBooked(foremanId)) return false;
    
    if (schedule.isSlotFull()) return false;
    
    return true;
  }

  Future<List<Schedule>> getAlternativeSlots(DateTime excludeDate) async {
    try {
      return await _scheduleRepository.getAlternativeSlots(excludeDate);
    } catch (e) {
      return [];
    }
  }

  Future<bool> canBookSlot(Schedule schedule) async {
    try {
      if (!checkAvailability(schedule)) return false;
      
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

  List<Schedule> getSchedulesByDayType(DayType dayType, DateTime date) {
    return getSchedulesForDate(date)
        .where((schedule) => schedule.dayType == dayType)
        .toList();
  }

  Future<bool> hasAnyBookings() async {
    try {
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