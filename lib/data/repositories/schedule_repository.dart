// lib/data/repositories/schedule_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';
import '../services/firestore_service.dart';

class ScheduleRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'schedules';

  ScheduleRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // Create a new schedule
  Future<String> createSchedule(Schedule schedule) async {
    try {
      return await _firestoreService.addDocument(_collection, schedule.toMap());
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  // Get all schedules for a workshop owner
  Stream<List<Schedule>> getSchedulesByWorkshop(String workshopId) {
    return _firestoreService
        .getCollectionWithQuery(_collection, 'workshop_id', workshopId)
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get available schedules for foreman booking
  Stream<List<Schedule>> getAvailableSchedules() {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('status', isEqualTo: 'available')
        .where('available_slots', isGreaterThan: 0)
        .orderBy('schedule_date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get schedules booked by a specific foreman
  Stream<List<Schedule>> getSchedulesByForeman(String foremanId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('foreman_ids', arrayContains: foremanId)
        .orderBy('schedule_date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Book a slot for a foreman
  Future<void> bookSlot(String scheduleId, String foremanId) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final scheduleRef = FirebaseFirestore.instance.collection(_collection).doc(scheduleId);
        final snapshot = await transaction.get(scheduleRef);
        
        if (!snapshot.exists) {
          throw Exception('Schedule not found');
        }

        final schedule = Schedule.fromMap(snapshot.data()!, scheduleId);
        
        // Check if foreman already booked this slot
        if (schedule.foremanIds.contains(foremanId)) {
          throw Exception('Already booked this slot');
        }
        
        // Check if slot is available
        if (schedule.availableSlots <= 0) {
          throw Exception('No available slots');
        }

        final updatedForemanIds = [...schedule.foremanIds, foremanId];
        final updatedAvailableSlots = schedule.availableSlots - 1;
        final newStatus = updatedAvailableSlots == 0 
            ? ScheduleStatus.full 
            : ScheduleStatus.available;

        transaction.update(scheduleRef, {
          'foreman_ids': updatedForemanIds,
          'available_slots': updatedAvailableSlots,
          'status': newStatus.toString().split('.').last,
          'updated_at': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to book slot: $e');
    }
  }

  // Cancel a booking
  Future<void> cancelBooking(String scheduleId, String foremanId) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final scheduleRef = FirebaseFirestore.instance.collection(_collection).doc(scheduleId);
        final snapshot = await transaction.get(scheduleRef);
        
        if (!snapshot.exists) {
          throw Exception('Schedule not found');
        }

        final schedule = Schedule.fromMap(snapshot.data()!, scheduleId);
        
        // Check if foreman has booked this slot
        if (!schedule.foremanIds.contains(foremanId)) {
          throw Exception('Booking not found');
        }

        final updatedForemanIds = schedule.foremanIds
            .where((id) => id != foremanId)
            .toList();
        final updatedAvailableSlots = schedule.availableSlots + 1;

        transaction.update(scheduleRef, {
          'foreman_ids': updatedForemanIds,
          'available_slots': updatedAvailableSlots,
          'status': ScheduleStatus.available.toString().split('.').last,
          'updated_at': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Update schedule
  Future<void> updateSchedule(String scheduleId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument(_collection, scheduleId, {
        ...updates,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _firestoreService.deleteDocument(_collection, scheduleId);
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }
}