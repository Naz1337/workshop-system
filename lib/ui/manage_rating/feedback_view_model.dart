import 'package:flutter/foundation.dart';
import '../../model/rating.dart';  
import '../../controllers/rating_controller.dart';  

class FeedbackViewModel with ChangeNotifier {
  bool _isSubmitting = false;
  String _submissionStatus = '';
  final RatingController ratingController;

  FeedbackViewModel({required this.ratingController});

  bool get isSubmitting => _isSubmitting;
  String get submissionStatus => _submissionStatus;

  Future<bool> submitRating(Rating feedback) async {
    _isSubmitting = true;
    notifyListeners();

    bool result;
    try {
      result = await ratingController.submitFeedback(feedback);
      _submissionStatus = result ? 'success' : 'error';
    } catch (e) {
      _submissionStatus = 'error';
      result = false;
      if (kDebugMode) {
        print('Error submitting feedback: $e');
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }

    return result;
  }

  void resetStatus() {
    _submissionStatus = '';
    notifyListeners();
  }
}