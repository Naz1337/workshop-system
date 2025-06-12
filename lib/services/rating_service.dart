import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ratings';

  // Save rating to Firebase
  Future<bool> saveRatingToFirebase(Rating rating) async {
    try {
      await _firestore.collection(_collection).add(rating.toMap());
      return true;
    } catch (e) {
      print('Error saving rating: $e');
      return false;
    }
  }

  // Get all ratings (for calculating averages)
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

  // Get ratings as a stream (for real-time updates)
  Stream<List<Rating>> getRatingsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Rating.fromFirestore(doc))
            .toList());
  }

  // Calculate average rating
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

  // Get total number of ratings
  Future<int> getTotalRatingsCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting count: $e');
      return 0;
    }
  }

  // Get rating statistics (for the header display)
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