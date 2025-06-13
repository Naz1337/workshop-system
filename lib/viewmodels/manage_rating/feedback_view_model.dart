import 'package:flutter/material.dart';
import '../../models/rating.dart';
import '../../repositories/rating_repository.dart';
import '../../services/auth_service.dart';

class FeedbackViewModel extends ChangeNotifier {
  final RatingRepository ratingRepository;
  final AuthService authService;

  FeedbackViewModel({
    required this.ratingRepository,
    required this.authService,
  }) {
    _initializeData();
  }

  // Form fields
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController jobTypeController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  // Rating data
  int _ratingStars = 0;
  double _averageRating = 0.0;
  int _totalRatingsCount = 0;
  List<Rating> _ratings = [];
  bool _isSubmitting = false;
  bool _showValidationErrors = false;
  
  // User role
  String? _userRole;
  String? _currentForemanId;
  bool _canSubmitRating = false;

  // Getters
  int get ratingStars => _ratingStars;
  double get averageRating => _averageRating;
  int get totalRatingsCount => _totalRatingsCount;
  List<Rating> get ratings => _ratings;
  bool get isSubmitting => _isSubmitting;
  bool get showValidationErrors => _showValidationErrors;
  String? get userRole => _userRole;
  bool get canSubmitRating => _canSubmitRating;

  bool get isFormValid {
    return _ratingStars > 0 &&
           customerNameController.text.trim().isNotEmpty &&
           jobTypeController.text.trim().isNotEmpty &&
           commentController.text.trim().isNotEmpty;
  }

  Stream<Map<String, dynamic>> get ratingStatisticsStream {
    return ratingRepository.getRatingsStream().map((ratings) {
      if (ratings.isEmpty) return {
        'averageRating': 0.0,
        'totalCount': 0,
      };

      final average = ratings.fold(0.0, (sum, r) => sum + r.stars) / ratings.length;
      return {
        'averageRating': average,
        'totalCount': ratings.length,
      };
    });
  }

  // Initialize data and user info
  // Future<void> _initializeData() async {
  //   try {
  //     // Get user role and permissions
  //     _userRole = await ratingRepository.getCurrentUserRole();
  //     _canSubmitRating = await ratingRepository.canSubmitRating();
  //     _currentForemanId = await authService.getCurrentForemanId();
      
  //     // Load initial statistics
  //     await _loadStatistics();
      
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error initializing feedback view model: $e');
  //   }
  // }

  // Add debug logs to your FeedbackViewModel _initializeData method

Future<void> _initializeData() async {
  try {
    print('🔄 DEBUG: FeedbackViewModel initializing...');
    
    // Get user role and permissions
    print('🔄 DEBUG: Getting current user role...');
    _userRole = await ratingRepository.getCurrentUserRole();
    print('✅ DEBUG: User role: $_userRole');
    
    print('🔄 DEBUG: Checking if user can submit rating...');
    _canSubmitRating = await ratingRepository.canSubmitRating();
    print('✅ DEBUG: Can submit rating: $_canSubmitRating');
    
    print('🔄 DEBUG: Getting current foreman ID...');
    _currentForemanId = await authService.getCurrentForemanId();
    print('✅ DEBUG: Current foreman ID: $_currentForemanId');
    
    // Load initial statistics
    print('🔄 DEBUG: Loading statistics...');
    await _loadStatistics();
    print('✅ DEBUG: Statistics loaded');
    
    notifyListeners();
  } catch (e) {
    print('❌ DEBUG: Error initializing feedback view model: $e');
    print('❌ DEBUG: Error type: ${e.runtimeType}');
    print('❌ DEBUG: Stack trace: ${StackTrace.current}');
  }
}

  // Load statistics based on user role
  Future<void> _loadStatistics() async {
    try {
      final stats = await ratingRepository.getRatingStatistics();
      _averageRating = stats['averageRating'] ?? 0.0;
      _totalRatingsCount = stats['totalCount'] ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }
  

  // Set rating stars
  void setRating(int rating) {
    _ratingStars = rating;
    notifyListeners();
  }

  // Set validation error state
  void setShowValidationErrors(bool show) {
    _showValidationErrors = show;
    notifyListeners();
  }

  // Submit rating
  Future<bool> submitRating(BuildContext context) async {
    if (!_canSubmitRating) {
      _showErrorMessage(context, 'Only foremen can submit ratings');
      return false;
    }

    if (_currentForemanId == null) {
      _showErrorMessage(context, 'Foreman not found. Please log in again.');
      return false;
    }

    if (!isFormValid) {
      _showErrorMessage(context, 'Please fill in all required fields');
      return false;
    }

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
        // Clear form immediately
        clearForm();
        
        // Force refresh statistics and ratings
        await Future.wait([
          _loadStatistics(),
          // If using streams, this will auto-update
        ]);
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Clear form
  void clearForm() {
    customerNameController.clear();
    jobTypeController.clear();
    commentController.clear();
    _ratingStars = 0;
    _showValidationErrors = false;
    notifyListeners();
  }

  // Refresh ratings and statistics
  Future<void> refreshRatings() async {
    await _loadStatistics();
  }

  // Show error message
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Check if user is workshop owner
  Future<bool> isWorkshopOwner() async {
    return await ratingRepository.canViewAllRatings();
  }

  // Check if user is foreman
  Future<bool> isForeman() async {
    return await ratingRepository.canSubmitRating();
  }

  // Get current foreman name for display
  Future<String?> getCurrentForemanName() async {
    try {
      final appUser = await authService.getCurrentAppUser();
      return appUser?.name;
    } catch (e) {
      print('Error getting foreman name: $e');
      return null;
    }
  }

  //missing getFieldError method for feedback_form_widget
  String? getFieldError(String fieldName) {
    if (!_showValidationErrors) return null;
    
    switch (fieldName) {
      case 'customerName':
        return customerNameController.text.trim().isEmpty ? 'Customer name is required' : null;
      case 'jobType':
        return jobTypeController.text.trim().isEmpty ? 'Job type is required' : null;
      case 'comment':
        return commentController.text.trim().isEmpty ? 'Comment is required' : null;
      case 'rating':
        return _ratingStars == 0 ? 'Rating is required' : null;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    customerNameController.dispose();
    jobTypeController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
