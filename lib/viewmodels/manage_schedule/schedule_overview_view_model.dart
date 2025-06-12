// lib/viewmodels/manage_schedule/schedule_overview_view_model.dart
import 'package:flutter/foundation.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';

class ScheduleOverviewViewModel extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository;
  final String workshopId;

  ScheduleOverviewViewModel({
    required ScheduleRepository scheduleRepository,
    required this.workshopId,
  }) : _scheduleRepository = scheduleRepository;

  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize stream
  void initialize() {
    _setLoading(true);
    _scheduleRepository.getSchedulesByWorkshop(workshopId).listen(
      (schedules) {
        _schedules = schedules;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = error.toString();
        _setLoading(false);
      },
    );
  }

  // Update schedule status
  Future<void> updateScheduleStatus(String scheduleId, ScheduleStatus status) async {
    try {
      await _scheduleRepository.updateSchedule(scheduleId, {
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _scheduleRepository.deleteSchedule(scheduleId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}