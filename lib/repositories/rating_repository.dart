import '../models/rating.dart';
import '../services/rating_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingRepository {
  final RatingService ratingService;
  final AuthService authService;

  RatingRepository({
    required this.ratingService,
    required this.authService,
  });

  // Submit a new rating (automatically links to current logged-in foreman)
  Future<bool> submitRating({
    required String customerName,
    required String jobType,
    required String comment,
    required int stars,
  }) async {
    try {
      // Get current foreman ID
      final foremanId = await authService.getCurrentForemanId();
      if (foremanId == null) {
        print('Error: No foreman logged in');
        return false;
      }

      final rating = Rating(
        customerName: customerName,
        jobType: jobType,
        comment: comment,
        stars: stars,
        foremanId: foremanId, // Link to current foreman
        timestamp: DateTime.now(),
      );

      return await ratingService.saveRatingToFirebase(rating);
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    }
  }

  // Get ratings based on user role
  Future<List<Rating>> getRatings() async {
    try {
      final isWorkshopOwner = await authService.isWorkshopOwner();
      
      if (isWorkshopOwner) {
        // Workshop owners can see all ratings
        return await ratingService.getAllRatings();
      } else {
        // Foremen can only see their own ratings
        final foremanId = await authService.getCurrentForemanId();
        if (foremanId == null) return [];
        
        return await ratingService.getRatingsForForeman(foremanId);
      }
    } catch (e) {
      print('Error getting ratings: $e');
      return [];
    }
  }

  // Get ratings stream based on user role (for real-time updates)
  Stream<List<Rating>> getRatingsStream() {
    return Stream.fromFuture(_getRatingsStreamBasedOnRole()).asyncExpand((stream) => stream);
  }

  Future<Stream<List<Rating>>> _getRatingsStreamBasedOnRole() async {
    try {
      final isWorkshopOwner = await authService.isWorkshopOwner();
      
      if (isWorkshopOwner) {
        // Workshop owners can see all ratings
        return ratingService.getRatingsStream();
      } else {
        // Foremen can only see their own ratings
        final foremanId = await authService.getCurrentForemanId();
        if (foremanId == null) {
          return Stream.value(<Rating>[]);
        }
        
        return ratingService.getRatingsStreamForForeman(foremanId);
      }
    } catch (e) {
      print('Error getting ratings stream: $e');
      return Stream.value(<Rating>[]);
    }
  }

  // Get average rating based on user role
  Future<double> getAverageRating() async {
    try {
      final isWorkshopOwner = await authService.isWorkshopOwner();
      
      if (isWorkshopOwner) {
        // Workshop owners see average of all foremen
        return await ratingService.getAverageRating();
      } else {
        // Foremen see their own average
        final foremanId = await authService.getCurrentForemanId();
        if (foremanId == null) return 0.0;
        
        return await ratingService.getAverageRatingForForeman(foremanId);
      }
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }

  // Get total ratings count based on user role
  Future<int> getTotalRatingsCount() async {
    try {
      final isWorkshopOwner = await authService.isWorkshopOwner();
      
      if (isWorkshopOwner) {
        // Workshop owners see total of all ratings
        return await ratingService.getTotalRatingsCount();
      } else {
        // Foremen see their own count
        final foremanId = await authService.getCurrentForemanId();
        if (foremanId == null) return 0;
        
        return await ratingService.getTotalRatingsCountForForeman(foremanId);
      }
    } catch (e) {
      print('Error getting total ratings count: $e');
      return 0;
    }
  }

  // Get comprehensive rating statistics based on user role
  Future<Map<String, dynamic>> getRatingStatistics() async {
    try {
      final isWorkshopOwner = await authService.isWorkshopOwner();
      
      if (isWorkshopOwner) {
        // Workshop owners see statistics for all foremen
        return await ratingService.getRatingStatistics();
      } else {
        // Foremen see their own statistics
        final foremanId = await authService.getCurrentForemanId();
        if (foremanId == null) {
          return {
            'averageRating': 0.0,
            'totalCount': 0,
            'distribution': [0, 0, 0, 0, 0],
          };
        }
        
        return await ratingService.getRatingStatisticsForForeman(foremanId);
      }
    } catch (e) {
      print('Error getting rating statistics: $e');
      return {
        'averageRating': 0.0,
        'totalCount': 0,
        'distribution': [0, 0, 0, 0, 0],
      };
    }
  }

  // Get ratings for specific foreman (workshop owner only)
  Future<List<Rating>> getRatingsForForeman(String foremanId) async {
    try {
      final isWorkshopOwner = await authService.isWorkshopOwner();
      if (!isWorkshopOwner) {
        print('Access denied: Only workshop owners can view other foremen ratings');
        return [];
      }
      
      return await ratingService.getRatingsForForeman(foremanId);
    } catch (e) {
      print('Error getting foreman ratings: $e');
      return [];
    }
  }

  // Check if current user can submit ratings (must be foreman)
  Future<bool> canSubmitRating() async {
    try {
      return await authService.isForeman();
    } catch (e) {
      print('Error checking submit permission: $e');
      return false;
    }
  }

  // Check if current user can view all ratings (must be workshop owner)
  Future<bool> canViewAllRatings() async {
    try {
      return await authService.isWorkshopOwner();
    } catch (e) {
      print('Error checking view permission: $e');
      return false;
    }
  }

  // Get current user role for UI display
  Future<String?> getCurrentUserRole() async {
    try {
      final appUser = await authService.getCurrentAppUser();
      return appUser?.role;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Delete rating (if needed for admin features)
  Future<bool> deleteRating(String ratingId) async {
    return await ratingService.deleteRating(ratingId);
  }

  // Update rating (if needed for edit features)
  Future<bool> updateRating(Rating rating) async {
    return await ratingService.updateRating(rating);
  }

  // Refresh ratings (useful for pull-to-refresh)
  Future<void> refreshRatings() async {
    // This method can be used to trigger a refresh in the UI
    // The actual refresh happens automatically with streams
  }
}