import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ratings';

  // Save rating to Firebase with foreman ID
  Future<bool> saveRatingToFirebase(Rating rating) async {
    try {
      await _firestore.collection(_collection).add(rating.toMap());
      return true;
    } catch (e) {
      print('Error saving rating: $e');
      return false;
    }
  }

  // Get all ratings (for workshop owners only)
  Future<List<Rating>> getAllRatings() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Rating.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting ratings: $e');
      return [];
    }
  }

  // NEW: Get ratings for specific foreman
  Future<List<Rating>> getRatingsForForeman(String foremanId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('foremanId', isEqualTo: foremanId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Rating.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting foreman ratings: $e');
      return [];
    }
  }

  // Get ratings as a stream (for real-time updates) - ALL ratings
  Stream<List<Rating>> getRatingsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Rating.fromFirestore(doc))
            .toList());
  }

  // NEW: Get ratings stream for specific foreman
  Stream<List<Rating>> getRatingsStreamForForeman(String foremanId) {
    return _firestore
        .collection(_collection)
        .where('foremanId', isEqualTo: foremanId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Rating.fromFirestore(doc))
            .toList());
  }

  // Calculate average rating for all foremen (workshop owner view)
  Future<double> getAverageRating() async {
    try {
      List<Rating> ratings = await getAllRatings();
      if (ratings.isEmpty) return 0.0;
      
      double total = ratings.fold(0.0, (sum, rating) => sum + rating.stars);
      return total / ratings.length;
    } catch (e) {
      print('Error calculating average: $e');
      return 0.0;
    }
  }

  // NEW: Calculate average rating for specific foreman
  Future<double> getAverageRatingForForeman(String foremanId) async {
    try {
      List<Rating> ratings = await getRatingsForForeman(foremanId);
      
      if (ratings.isEmpty) return 0.0;
      
      double total = ratings.fold(0.0, (sum, rating) => sum + rating.stars);
      return total / ratings.length;
    } catch (e) {
      print('Error calculating foreman average: $e');
      return 0.0;
    }
  }

  // Get total number of ratings (all)
  Future<int> getTotalRatingsCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting count: $e');
      return 0;
    }
  }

  // NEW: Get total ratings count for specific foreman
  Future<int> getTotalRatingsCountForForeman(String foremanId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('foremanId', isEqualTo: foremanId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting foreman count: $e');
      return 0;
    }
  }

  // Get rating statistics (for all foremen - workshop owner view)
  Future<Map<String, dynamic>> getRatingStatistics() async {
    try {
      List<Rating> ratings = await getAllRatings();
      
      if (ratings.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalCount': 0,
          'distribution': [0, 0, 0, 0, 0], // 1-star to 5-star counts
        };
      }

      double average = ratings.fold(0.0, (sum, rating) => sum + rating.stars) / ratings.length;
      
      // Calculate star distribution
      List<int> distribution = [0, 0, 0, 0, 0];
      for (Rating rating in ratings) {
        if (rating.stars >= 1 && rating.stars <= 5) {
          distribution[rating.stars - 1]++;
        }
      }

      return {
        'averageRating': average,
        'totalCount': ratings.length,
        'distribution': distribution,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'averageRating': 0.0,
        'totalCount': 0,
        'distribution': [0, 0, 0, 0, 0],
      };
    }
  }

  // NEW: Get rating statistics for specific foreman
  Future<Map<String, dynamic>> getRatingStatisticsForForeman(String foremanId) async {
    try {
      List<Rating> ratings = await getRatingsForForeman(foremanId);
      
      if (ratings.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalCount': 0,
          'distribution': [0, 0, 0, 0, 0],
        };
      }

      double average = ratings.fold(0.0, (sum, rating) => sum + rating.stars) / ratings.length;
      
      // Calculate star distribution
      List<int> distribution = [0, 0, 0, 0, 0];
      for (Rating rating in ratings) {
        if (rating.stars >= 1 && rating.stars <= 5) {
          distribution[rating.stars - 1]++;
        }
      }

      return {
        'averageRating': average,
        'totalCount': ratings.length,
        'distribution': distribution,
      };
    } catch (e) {
      print('Error getting foreman statistics: $e');
      return {
        'averageRating': 0.0,
        'totalCount': 0,
        'distribution': [0, 0, 0, 0, 0],
      };
    }
  }

  // Delete a rating (if needed)
  Future<bool> deleteRating(String ratingId) async {
    try {
      await _firestore.collection(_collection).doc(ratingId).delete();
      return true;
    } catch (e) {
      print('Error deleting rating: $e');
      return false;
    }
  }

  // Update a rating (if needed)
  Future<bool> updateRating(Rating rating) async {
    try {
      if (rating.id == null) return false;
      
      await _firestore
          .collection(_collection)
          .doc(rating.id)
          .update(rating.toMap());
      return true;
    } catch (e) {
      print('Error updating rating: $e');
      return false;
    }
  }
}