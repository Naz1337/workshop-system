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
  final int maxForeman;
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
    required this.maxForeman,
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
      maxForeman: map['max_foreman'] ?? 3,
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
      'max_foreman': maxForeman,
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
      maxForeman: maxForeman ?? this.maxForeman,
      availableSlots: availableSlots ?? this.availableSlots,
      foremanIds: foremanIds ?? this.foremanIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}