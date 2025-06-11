// lib/data/models/schedule.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum DayType { morning, afternoon, evening }
enum ScheduleStatus { available, full, cancelled }

class Schedule {
  final String scheduleId;
  final String workshopId;
  final DateTime scheduleDate;
  final DateTime startTime;
  final DateTime endTime;
  final DayType dayType;
  final int maxForeman; // Fixed at 3 according to SRS
  final int availableSlots;
  final List<String> foremanIds;
  final ScheduleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.scheduleId,
    required this.workshopId,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.dayType,
    this.maxForeman = 3, // SRS: Fixed maximum of 3 foremen per slot
    required this.availableSlots,
    required this.foremanIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromMap(Map<String, dynamic> map, String id) {
    return Schedule(
      scheduleId: id,
      workshopId: map['workshop_id'] ?? '',
      scheduleDate: (map['schedule_date'] as Timestamp).toDate(),
      startTime: (map['start_time'] as Timestamp).toDate(),
      endTime: (map['end_time'] as Timestamp).toDate(),
      dayType: DayType.values.firstWhere(
        (e) => e.toString().split('.').last == map['day_type'],
        orElse: () => DayType.morning,
      ),
      maxForeman: 3, // SRS requirement: Always 3
      availableSlots: map['available_slots'] ?? 0,
      foremanIds: List<String>.from(map['foreman_ids'] ?? []),
      status: ScheduleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ScheduleStatus.available,
      ),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workshop_id': workshopId,
      'schedule_date': Timestamp.fromDate(scheduleDate),
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'day_type': dayType.toString().split('.').last,
      'max_foreman': 3, // SRS requirement: Always 3
      'available_slots': availableSlots,
      'foreman_ids': foremanIds,
      'status': status.toString().split('.').last,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  Schedule copyWith({
    String? scheduleId,
    String? workshopId,
    DateTime? scheduleDate,
    DateTime? startTime,
    DateTime? endTime,
    DayType? dayType,
    int? maxForeman,
    int? availableSlots,
    List<String>? foremanIds,
    ScheduleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      scheduleId: scheduleId ?? this.scheduleId,
      workshopId: workshopId ?? this.workshopId,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dayType: dayType ?? this.dayType,
      maxForeman: 3, // Always 3 according to SRS
      availableSlots: availableSlots ?? this.availableSlots,
      foremanIds: foremanIds ?? this.foremanIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // SRS Business Rules Validation
  bool canAcceptMoreForemen() {
    return foremanIds.length < 3 && availableSlots > 0;
  }

  bool isForemanAlreadyBooked(String foremanId) {
    return foremanIds.contains(foremanId);
  }

  bool isSlotFull() {
    return foremanIds.length >= 3 || availableSlots <= 0;
  }
}