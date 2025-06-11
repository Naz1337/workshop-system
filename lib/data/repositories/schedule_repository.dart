// lib/data/repositories/schedule_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';
import '../services/firestore_service.dart';

class ScheduleRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'schedules';

  ScheduleRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // Create a new schedule - SRS Requirement WMS-RQ-02-02
  Future<String> createSchedule(Schedule schedule) async {
    try {
      return await _firestoreService.addDocument(_collection, schedule.toMap());
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  // Get all schedules for a workshop owner - SRS Requirement WMS-RQ-02-01
  Stream<List<Schedule>> getSchedulesByWorkshop(String workshopId) {
    return _firestoreService
        .getCollectionWithQuery(_collection, 'workshop_id', workshopId)
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get available schedules for foreman booking - Enhanced with SRS rules
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

  // SRS Business Rule: Check if foreman already has a booking for the same date
  Future<bool> hasBookingOnDate(String foremanId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('foreman_ids', arrayContains: foremanId)
          .where('schedule_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('schedule_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check existing bookings: $e');
    }
  }

  // Enhanced booking with SRS business rules - WMS-RQ-02-03, WMS-RQ-02-04
  Future<void> bookSlot(String scheduleId, String foremanId) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final scheduleRef = FirebaseFirestore.instance.collection(_collection).doc(scheduleId);
        final snapshot = await transaction.get(scheduleRef);
        
        if (!snapshot.exists) {
          throw Exception('Schedule not found');
        }

        final schedule = Schedule.fromMap(snapshot.data()!, scheduleId);
        
        // SRS Rule: Check if foreman already booked this slot (Double Booking - E2)
        if (schedule.isForemanAlreadyBooked(foremanId)) {
          throw DoubleBookingException('You have already booked this slot. Please check "My Schedule" page.');
        }

        // SRS Rule: Check if foreman already has booking on same date
        final hasExistingBooking = await hasBookingOnDate(foremanId, schedule.scheduleDate);
        if (hasExistingBooking) {
          throw OneSlotPerDayException('You can only book one slot per day. Please choose a different date.');
        }
        
        // SRS Rule: Check if slot is full (Slot Full - E1)
        if (schedule.isSlotFull()) {
          throw SlotFullException('This slot is full. Please select another slot.');
        }

        // Update the schedule
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

        // TODO: Implement notification to workshop owner (SRS WMS-RQ-02-06)
        await _notifyWorkshopOwner(schedule.workshopId, 'booking', scheduleId, foremanId);
      });
    } catch (e) {
      if (e is DoubleBookingException || e is OneSlotPerDayException || e is SlotFullException) {
        rethrow;
      }
      throw Exception('Failed to book slot: $e');
    }
  }

  // Enhanced cancellation with SRS requirements - WMS-RQ-02-07, WMS-RQ-02-08
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
        if (!schedule.isForemanAlreadyBooked(foremanId)) {
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

        // SRS Requirement: Notify workshop owner (WMS-RQ-02-09)
        await _notifyWorkshopOwner(schedule.workshopId, 'cancellation', scheduleId, foremanId);
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get alternative available slots for error handling (SRS E1 flow)
  Future<List<Schedule>> getAlternativeSlots(DateTime excludeDate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('status', isEqualTo: 'available')
          .where('available_slots', isGreaterThan: 0)
          .orderBy('schedule_date', descending: false)
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => Schedule.fromMap(doc.data(), doc.id))
          .where((schedule) => !_isSameDay(schedule.scheduleDate, excludeDate))
          .toList();
    } catch (e) {
      throw Exception('Failed to get alternative slots: $e');
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

  // Private helper methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // TODO: Implement notification system
  Future<void> _notifyWorkshopOwner(String workshopId, String action, String scheduleId, String foremanId) async {
    // This should implement the notification system mentioned in SRS
    // For now, we'll just log it
    print('Notification: $action by $foremanId for schedule $scheduleId in workshop $workshopId');
  }
}

// Custom exceptions for SRS error flows
class DoubleBookingException implements Exception {
  final String message;
  DoubleBookingException(this.message);
  
  @override
  String toString() => message;
}

class OneSlotPerDayException implements Exception {
  final String message;
  OneSlotPerDayException(this.message);
  
  @override
  String toString() => message;
}

class SlotFullException implements Exception {
  final String message;
  SlotFullException(this.message);
  
  @override
  String toString() => message;
}