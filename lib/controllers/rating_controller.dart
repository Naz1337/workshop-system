import '../model/rating.dart';
import '../repository/rating_repository.dart';
import 'package:flutter/foundation.dart';


class RatingController {
  final RatingRepository _ratingRepository;

  RatingController({required RatingRepository ratingRepository})
      : _ratingRepository = ratingRepository;

  /// Submits feedback to the repository
  /// Returns [true] if successful, [false] if failed
  Future<bool> submitFeedback(Rating feedback) async {
    try {
      // Step 3: Save feedback through repository
      await _ratingRepository.saveFeedback(feedback);
      
      // Step 4: Return success
      return true;
    } catch (error) {
      // Steps 5-7: Handle and log error
      debugPrint('Submission error: $error');
      return false;
    }
  }
}