import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manage_rating/feedback_view_model.dart';
import '../../models/rating.dart';
import 'rating_star_widget.dart';
import 'user_rating_screen.dart';

class AllRatingsScreen extends StatefulWidget {
  const AllRatingsScreen({Key? key}) : super(key: key);

  @override
  State<AllRatingsScreen> createState() => _AllRatingsScreenState();
}

class _AllRatingsScreenState extends State<AllRatingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _userRole;
  String? _foremanName;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    
    try {
      final userRole = viewModel.userRole;
      final foremanName = await viewModel.getCurrentForemanName();
      
      if (mounted) {
        setState(() {
          _userRole = userRole;
          _foremanName = foremanName;
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Widget _buildUserInfoHeader() {
    if (_userRole == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: _userRole == 'workshop_owner' 
                  ? [Colors.purple[600]!, Colors.purple[400]!]
                  : [Colors.green[600]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  _userRole == 'workshop_owner' 
                      ? Icons.admin_panel_settings
                      : Icons.engineering,
                  color: _userRole == 'workshop_owner' 
                      ? Colors.purple[600]
                      : Colors.green[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userRole == 'workshop_owner' 
                          ? 'Workshop Owner View'
                          : 'Foreman View',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userRole == 'workshop_owner' 
                          ? 'Viewing all foremen ratings'
                          : 'Viewing ratings for: ${_foremanName ?? 'You'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _userRole == 'workshop_owner' 
                    ? Icons.visibility
                    : Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _userRole == 'workshop_owner' 
              ? "All Ratings (All Foremen)"
              : "My Ratings",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FeedbackViewModel>(
        builder: (context, viewModel, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // User Info Header
                _buildUserInfoHeader(),

                // Average Rating Display Header with stream
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: StreamBuilder<Map<String, dynamic>>(
                      stream: viewModel.ratingStatisticsStream,
                      builder: (context, snapshot) {
                        // Handle loading state
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.blue[600]!, Colors.blue[400]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          );
                        }

                        // Handle error state
                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.red[600]!, Colors.red[400]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Error loading statistics",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Get statistics from stream
                        final stats = snapshot.data ?? {'averageRating': 0.0, 'totalCount': 0};
                        final averageRating = stats['averageRating'] as double;
                        final totalCount = stats['totalCount'] as int;

                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.blue[600]!, Colors.blue[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _userRole == 'workshop_owner' 
                                    ? "Overall Average Rating"
                                    : "My Average Rating",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      RatingStarWidget(
                                        rating: averageRating.round(),
                                        size: 24,
                                        isInteractive: false,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$totalCount reviews",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Ratings List using StreamBuilder
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => viewModel.refreshRatings(),
                    child: StreamBuilder<List<Rating>>(
                      stream: viewModel.ratingRepository.getRatingsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && 
                            !snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        
                        final ratings = snapshot.data ?? [];
                        
                        if (ratings.isEmpty) {
                          return _buildEmptyState();
                        }
                        
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: ratings.length,
                          itemBuilder: (context, index) {
                            return _buildRatingCard(ratings[index], index);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingCard(Rating rating, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section with name and rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      rating.customerName.isNotEmpty 
                          ? rating.customerName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and Date section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Name
                        Text(
                          rating.customerName.isEmpty ? 'Anonymous' : rating.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        
                        // Rating Date
                        Text(
                          _formatDate(rating.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        // Show foreman info for workshop owners
                        if (_userRole == 'workshop_owner' && rating.foremanId.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Foreman ID: ${rating.foremanId}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Star Rating
                  RatingStarWidget(
                    rating: rating.stars,
                    size: 18,
                    isInteractive: false,
                  ),
                ],
              ),
              
              // Job Type (if available)
              if (rating.jobType.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    rating.jobType,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              
              // Comment (if available)
              if (rating.comment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    rating.comment,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _userRole == 'workshop_owner' 
                ? "No ratings yet from any foremen"
                : "No ratings yet for you",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userRole == 'workshop_owner' 
                ? "Ratings will appear here when foremen receive them"
                : "Your customer ratings will appear here",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown date';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        } else {
          return '${difference.inMinutes}m ago';
        }
      } else {
        return '${difference.inHours}h ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}