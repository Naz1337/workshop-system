// lib/data/repositories/schedule_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';
import '/services/firestore_service.dart';

class ScheduleRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'schedules';

  ScheduleRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<String> createSchedule(Schedule schedule) async {
    try {
      return await _firestoreService.addDocument(collectionPath: _collection, data: schedule.toMap());
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  Stream<List<Schedule>> getSchedulesByWorkshop(String workshopId) {
    return _firestoreService
        .getCollectionWithQuery(_collection, 'workshop_id', workshopId)
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Simplified query to avoid index issues
  Stream<List<Schedule>> getAvailableSchedules() {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data(), doc.id))
            .where((schedule) => schedule.availableSlots > 0) // 
            .toList()..sort((a, b) => a.scheduleDate.compareTo(b.scheduleDate))); 
  }

  // Simplified query for foreman schedules
  Stream<List<Schedule>> getSchedulesByForeman(String foremanId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('foreman_ids', arrayContains: foremanId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.data(), doc.id))
            .toList()..sort((a, b) => a.scheduleDate.compareTo(b.scheduleDate)));
  }

  // Simplified check for existing bookings
  Future<bool> hasBookingOnDate(String foremanId, DateTime date) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('foreman_ids', arrayContains: foremanId)
          .get();

      for (var doc in snapshot.docs) {
        final schedule = Schedule.fromMap(doc.data(), doc.id);
        if (_isSameDay(schedule.scheduleDate, date)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check existing bookings: $e');
    }
  }

  Future<void> bookSlot(String scheduleId, String foremanId) async {
    try {
      await _firestoreService.runTransaction((transaction) async {
        final scheduleRef = FirebaseFirestore.instance.collection(_collection).doc(scheduleId);
        final snapshot = await transaction.get(scheduleRef);
        
        if (!snapshot.exists) {
          throw Exception('Schedule not found');
        }

        final schedule = Schedule.fromMap(snapshot.data()!, scheduleId);
        
        if (schedule.isForemanAlreadyBooked(foremanId)) {
          throw DoubleBookingException('You have already booked this slot. Please check "My Schedule" page.');
        }

        final hasExistingBooking = await hasBookingOnDate(foremanId, schedule.scheduleDate);
        if (hasExistingBooking) {
          throw OneSlotPerDayException('You can only book one slot per day. Please choose a different date.');
        }
        
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

        await _notifyWorkshopOwner(schedule.workshopId, 'booking', scheduleId, foremanId);
      });
    } catch (e) {
      if (e is DoubleBookingException || e is OneSlotPerDayException || e is SlotFullException) {
        rethrow;
      }
      throw Exception('Failed to book slot: $e');
    }
  }

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

        await _notifyWorkshopOwner(schedule.workshopId, 'cancellation', scheduleId, foremanId);
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Slots query
  Future<List<Schedule>> getAlternativeSlots(DateTime excludeDate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('status', isEqualTo: 'available')
          .limit(10) 
          .get();

      return snapshot.docs
          .map((doc) => Schedule.fromMap(doc.data(), doc.id))
          .where((schedule) => 
              schedule.availableSlots > 0 && 
              !_isSameDay(schedule.scheduleDate, excludeDate))
          .take(5) // Take top 5 after filtering
          .toList();
    } catch (e) {
      throw Exception('Failed to get alternative slots: $e');
    }
  }

  // Update schedule
  Future<void> updateSchedule(String scheduleId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument(collectionPath: _collection, documentId: scheduleId, data: {
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
      await _firestoreService.deleteDocument(collectionPath: _collection, documentId: scheduleId);
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  Future<void> _notifyWorkshopOwner(String workshopId, String action, String scheduleId, String foremanId) async {
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
