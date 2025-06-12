// lib/viewmodels/manage_schedule/my_schedule_view_model.dart
import 'package:flutter/foundation.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';

class MyScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository;
  final String foremanId;

  MyScheduleViewModel({
    required ScheduleRepository scheduleRepository,
    required this.foremanId,
  }) : _scheduleRepository = scheduleRepository;

  List<Schedule> _mySchedules = [];
  bool _isLoading = false;
  bool _isCancelling = false;
  String? _errorMessage;
  String? _successMessage;

  List<Schedule> get mySchedules => _mySchedules;
  bool get isLoading => _isLoading;
  bool get isCancelling => _isCancelling;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Get upcoming schedules
  List<Schedule> get upcomingSchedules {
    final now = DateTime.now();
    return _mySchedules
        .where((schedule) => schedule.scheduleDate.isAfter(now))
        .toList();
  }

  // Get past schedules
  List<Schedule> get pastSchedules {
    final now = DateTime.now();
    return _mySchedules
        .where((schedule) => schedule.scheduleDate.isBefore(now))
        .toList();
  }

  // Initialize stream
  void initialize() {
    _setLoading(true);
    _scheduleRepository.getSchedulesByForeman(foremanId).listen(
      (schedules) {
        _mySchedules = schedules;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = error.toString();
        _setLoading(false);
      },
    );
  }

  // Cancel a booking
  Future<void> cancelBooking(String scheduleId) async {
    _setCancelling(true);
    _clearMessages();

    try {
      await _scheduleRepository.cancelBooking(scheduleId, foremanId);
      _successMessage = 'Booking cancelled successfully';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setCancelling(false);
    }
  }

  // Check if booking can be cancelled 
  bool canCancelBooking(Schedule schedule) {
    final now = DateTime.now();
    final timeDifference = schedule.scheduleDate.difference(now);
    return timeDifference.inHours > 24; 
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCancelling(bool cancelling) {
    _isCancelling = cancelling;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() => _clearMessages();
}