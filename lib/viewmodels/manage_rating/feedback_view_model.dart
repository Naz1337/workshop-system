import 'package:flutter/material.dart';
import '../../repositories/rating_repository.dart';
import '../../models/rating.dart';

class FeedbackViewModel extends ChangeNotifier {
  final RatingRepository ratingRepository;

  FeedbackViewModel({required this.ratingRepository}) {
    _loadRatingStatistics();
    loadAllRatings();
  }

  // Controllers for form fields
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController jobTypeController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  // Rating state
  int _ratingStars = 0;
  int get ratingStars => _ratingStars;

  // UI state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _showValidationErrors = false;
  bool get showValidationErrors => _showValidationErrors;

  // Statistics for display
  double _averageRating = 0.0;
  double get averageRating => _averageRating;

  int _totalRatingsCount = 0;
  int get totalRatingsCount => _totalRatingsCount;

  List<int> _ratingDistribution = [0, 0, 0, 0, 0];
  List<int> get ratingDistribution => _ratingDistribution;

  // All ratings list
  List<Rating> _allRatings = [];
  bool _isLoadingRatings = false;

  // Getters
  List<Rating> get allRatings => _allRatings;
  bool get isLoading => _isLoadingRatings;

  // Set rating
  void setRating(int rating) {
    _ratingStars = rating;
    notifyListeners();
  }

  // Set validation errors visibility
  void setShowValidationErrors(bool show) {
    _showValidationErrors = show;
    notifyListeners();
  }

  // Load rating statistics from Firebase
  Future<void> _loadRatingStatistics() async {
    try {
      final stats = await ratingRepository.getRatingStatistics();
      _averageRating = stats['averageRating'];
      _totalRatingsCount = stats['totalCount'];
      _ratingDistribution = List<int>.from(stats['distribution']);
      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // Refresh statistics (call this after submitting a rating)
  Future<void> refreshStatistics() async {
    await _loadRatingStatistics();
  }

  // Submit rating
  Future<bool> submitRating(BuildContext context) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final success = await ratingRepository.submitRating(
        customerName: customerNameController.text.trim(),
        jobType: jobTypeController.text.trim(),
        comment: commentController.text.trim(),
        stars: _ratingStars,
      );

      if (success) {
        await Future.wait([
          refreshStatistics(),
          loadAllRatings(),
        ]);
        
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Clear form data
  void clearForm() {
    customerNameController.clear();
    jobTypeController.clear();
    commentController.clear();
    _ratingStars = 0;
    _showValidationErrors = false;
    notifyListeners();
  }

  // Validation
  bool get isFormValid {
    return customerNameController.text.trim().isNotEmpty &&
           jobTypeController.text.trim().isNotEmpty &&
           _ratingStars > 0;
  }

  // Get validation message for specific field
  String? getFieldError(String fieldName) {
    if (!_showValidationErrors) return null;

    switch (fieldName) {
      case 'customerName':
        return customerNameController.text.trim().isEmpty ? 'Customer name is required' : null;
      case 'jobType':
        return jobTypeController.text.trim().isEmpty ? 'Job type is required' : null;
      case 'rating':
        return _ratingStars == 0 ? 'Please select a rating' : null;
      default:
        return null;
    }
  }

  // Method to load all ratings
  Future<void> loadAllRatings() async {
    _isLoadingRatings = true;
    notifyListeners();

    try {
      _allRatings = await ratingRepository.getAllRatings();
      // Also refresh statistics when loading all ratings
      await _loadRatingStatistics();
    } catch (e) {
      print('Error loading all ratings: $e');
      _allRatings = [];
    } finally {
      _isLoadingRatings = false;
      notifyListeners();
    }
  }

  // Method to filter ratings by star count
  List<Rating> getRatingsByStars(int stars) {
    return _allRatings.where((rating) => rating.stars == stars).toList();
  }

  // Method to get ratings by customer name
  List<Rating> getRatingsByCustomer(String customerName) {
    return _allRatings
        .where((rating) => 
            rating.customerName.toLowerCase().contains(customerName.toLowerCase()))
        .toList();
  }

  // Method to get ratings by job type
  List<Rating> getRatingsByJobType(String jobType) {
    return _allRatings
        .where((rating) => 
            rating.jobType.toLowerCase().contains(jobType.toLowerCase()))
        .toList();
  }

  // Method to get recent ratings (last 30 days)
  List<Rating> getRecentRatings() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _allRatings
        .where((rating) => 
            rating.timestamp?.isAfter(thirtyDaysAgo) == true)
        .toList();
  }

  // Method to delete a rating
  Future<bool> deleteRating(String ratingId) async {
    try {
      final success = await ratingRepository.deleteRating(ratingId);
      if (success) {
        // Remove from local list
        _allRatings.removeWhere((rating) => rating.id == ratingId);
        // Refresh statistics
        await _loadRatingStatistics();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting rating: $e');
      return false;
    }
  }

  // Method to refresh ratings (for pull-to-refresh)
  Future<void> refreshRatings() async {
    await loadAllRatings();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    jobTypeController.dispose();
    commentController.dispose();
    super.dispose();
  }
}