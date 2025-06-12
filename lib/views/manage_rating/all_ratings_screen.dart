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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Widget _buildNavigationDrawer(BuildContext context) {
  //   return Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: [
  //         const DrawerHeader(
  //           decoration: BoxDecoration(
  //             color: Colors.blue,
  //           ),
  //           child: Text(
  //             'Navigation Menu',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 24,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.star),
  //           title: const Text('Rating Screen'),
  //           onTap: () {
  //             Navigator.pop(context); // Close the drawer
  //             // Only navigate if we're not already on the rating screen
  //             if (!ModalRoute.of(context)!.isCurrent) {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => const UserRatingScreen(),
  //                 ),
  //               );
  //             }
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.list),
  //           title: const Text('All Ratings Screen'),
  //           onTap: () {
  //             Navigator.pop(context); // Close the drawer
  //             // Only navigate if we're not already on the all ratings screen
  //             if (!ModalRoute.of(context)!.isCurrent) {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => const AllRatingsScreen(),
  //                 ),
  //               );
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: _buildNavigationDrawer(context),
      appBar: AppBar(
        title: const Text(
          "All Ratings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(  // This is the key fix
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Consumer<FeedbackViewModel>(
        builder: (context, viewModel, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Average Rating Display Header
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
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
                          const Text(
                            "Average Rating",
                            style: TextStyle(
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
                                viewModel.averageRating.toStringAsFixed(1),
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
                                    rating: viewModel.averageRating.round(),
                                    size: 24,
                                    isInteractive: false,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${viewModel.totalRatingsCount} reviews",
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
                    ),
                  ),
                ),
                
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

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Navigation Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rating Screen'),
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/rating') {
                Navigator.pushReplacementNamed(context, '/rating');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All Ratings Screen'),
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/all-ratings') {
                Navigator.pushReplacementNamed(context, '/all-ratings');
              }
            },
          ),
        ],
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
            "No ratings yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to leave a review!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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