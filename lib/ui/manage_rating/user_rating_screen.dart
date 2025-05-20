import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feedback_form_widget.dart';
import 'feedback_view_model.dart';
import 'rating_star_widget.dart';
import '../../model/rating.dart';  // Import Rating model

class UserRatingScreen extends StatefulWidget {
  const UserRatingScreen({super.key});

  @override
  State<UserRatingScreen> createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;

  @override
  void dispose() {
    _customerNameController.dispose();
    _jobTypeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final feedbackViewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    
    if (_customerNameController.text.isEmpty || _selectedRating == 0) {
      _showErrorDialog("Please provide your name and rating.");
      return;
    }

    // Corrected: Using Rating model constructor
    final feedback = Rating(
      customerName: _customerNameController.text,
      jobType: _jobTypeController.text,
      comment: _commentController.text,
      stars: _selectedRating,
    );

    final result = await feedbackViewModel.submitRating(feedback);
    
    if (result) {
      _showSuccessDialog("Thank you for your feedback!");
      _customerNameController.clear();
      _jobTypeController.clear();
      _commentController.clear();
      setState(() => _selectedRating = 0);
    } else {
      _showErrorDialog("Submission failed. Please try again.");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'How would you rate your experience?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Corrected RatingStarWidget with proper parameters
            Center(
              child: RatingStarWidget(
                rating: _selectedRating,
                onRatingSelected: (rating) {
                  setState(() => _selectedRating = rating);
                },
              ),
            ),
            const SizedBox(height: 30),
            
            // Corrected FeedbackFormWidget with proper parameters
            FeedbackFormWidget(
              nameController: _customerNameController,
              jobTypeController: _jobTypeController,
              commentController: _commentController,
              onSubmit: _submitFeedback,
            ),
          ],
        ),
      ),
    );
  }
}