import '../models/rating.dart';
import '../services/rating_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingRepository {
  final RatingService ratingService;

  RatingRepository({required this.ratingService});

  // Submit a new rating
  Future<bool> submitRating({
    required String customerName,
    required String jobType,
    required String comment,
    required int stars,
  }) async {
    final rating = Rating(
      customerName: customerName,
      jobType: jobType,
      comment: comment,
      stars: stars,
      timestamp: DateTime.now(),
    );

    return await ratingService.saveRatingToFirebase(rating);
  }

  // Get all ratings
  Future<List<Rating>> getAllRatings() async {
    return await ratingService.getAllRatings();
  }

  // Get ratings as stream for real-time updates
  Stream<List<Rating>> getRatingsStream() {
    return ratingService.getRatingsStream();
  }

  // Get average rating
  Future<double> getAverageRating() async {
    return await ratingService.getAverageRating();
  }

  // Get total ratings count
  Future<int> getTotalRatingsCount() async {
    return await ratingService.getTotalRatingsCount();
  }

  // Get comprehensive rating statistics
  Future<Map<String, dynamic>> getRatingStatistics() async {
    return await ratingService.getRatingStatistics();
  }

  // Delete rating (if needed for admin features)
  Future<bool> deleteRating(String ratingId) async {
    return await ratingService.deleteRating(ratingId);
  }

  // Update rating (if needed for edit features)
  Future<bool> updateRating(Rating rating) async {
    return await ratingService.updateRating(rating);
  }
}