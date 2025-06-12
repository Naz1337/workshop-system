import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manage_rating/feedback_view_model.dart';
import 'feedback_form_widget.dart';
import 'rating_star_widget.dart';
import 'all_ratings_screen.dart';

class UserRatingScreen extends StatefulWidget {
  const UserRatingScreen({Key? key}) : super(key: key);

  @override
  State<UserRatingScreen> createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
  

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            const Text("Submitting your feedback..."),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Thank You!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your feedback helps us improve our service",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              
              // Clear the form using the correct method name
              final viewModel = Provider.of<FeedbackViewModel>(
                context, 
                listen: false
              );
              viewModel.clearForm();
              
              // Return to previous screen if possible
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  void _showCustomSnackBar(
    BuildContext context, 
    String message, 
    IconData icon, 
    Color color
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: _buildNavigationDrawer(context),
      appBar: AppBar(
        title: const Text(
          "Rating and Review",
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
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card with Average Rating
                    Card(
                      elevation: 2,
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
                              Icons.engineering,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Foreman Average Rating",
                              style: TextStyle(
                                fontSize: 16,
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
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    RatingStarWidget(
                                      rating: viewModel.averageRating.round(),
                                      size: 20,
                                      isInteractive: false,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${viewModel.totalRatingsCount} reviews",
                                      style: const TextStyle(
                                        fontSize: 12,
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
                    
                    const SizedBox(height: 24),
                    
                    // Rate the Foreman Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_outline,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Rate the Foreman",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                RatingStarWidget(
                                  rating: viewModel.ratingStars,
                                  size: 48,
                                  onRatingSelected: viewModel.setRating,
                                ),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: viewModel.ratingStars > 0
                                      ? Container(
                                          key: ValueKey(viewModel.ratingStars),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            const [
                                              'Poor',
                                              'Fair', 
                                              'Good',
                                              'Very Good',
                                              'Excellent'
                                            ][viewModel.ratingStars - 1],
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                if (viewModel.showValidationErrors && 
                                    viewModel.ratingStars == 0)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      "*Required",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Form Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: FeedbackFormWidget(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          // Validate form
                          viewModel.setShowValidationErrors(true);
                          
                          if (!viewModel.isFormValid) {
                            _showCustomSnackBar(
                              context, 
                              "Please fill in all required fields", 
                              Icons.warning_amber_rounded,
                              Colors.orange,
                            );
                            return;
                          }
                          
                          _showLoadingDialog(context);
                          final success = await viewModel.submitRating(context);
                          Navigator.of(context).pop(); // Close loading dialog
                          
                          if (success) {
                            _showSuccessDialog(context);
                          } else {
                            _showCustomSnackBar(
                              context, 
                              "Submission failed. Please try again", 
                              Icons.error_outline,
                              Colors.red,
                            );
                          }
                        },
                        child: viewModel.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Submit Feedback",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Privacy note
                    Text(
                      "Your feedback is anonymous and helps us improve our services",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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

  
}