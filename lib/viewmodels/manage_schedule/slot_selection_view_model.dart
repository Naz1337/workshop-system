// lib/viewmodels/manage_schedule/slot_selection_view_model.dart
import 'package:flutter/foundation.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';

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

  // Getters
  List<Schedule> get availableSchedules => _availableSchedules;
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Initialize stream
  void initialize() {
    _setLoading(true);
    _scheduleRepository.getAvailableSchedules().listen(
      (schedules) {
        _availableSchedules = schedules;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = error.toString();
        _setLoading(false);
      },
    );
  }

  // Book a slot
  Future<void> bookSlot(String scheduleId) async {
    _setBooking(true);
    _clearMessages();

    try {
      await _scheduleRepository.bookSlot(scheduleId, foremanId);
      _successMessage = 'Slot booked successfully';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setBooking(false);
    }
  }

  // Check availability before booking
  bool checkAvailability(Schedule schedule) {
    return schedule.status == ScheduleStatus.available &&
           schedule.availableSlots > 0 &&
           !schedule.foremanIds.contains(foremanId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setBooking(bool booking) {
    _isBooking = booking;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() => _clearMessages();
}