import 'package:flutter/material.dart';

class FeedbackFormWidget extends StatefulWidget {
  final Function(String, String, String, int) onSubmit;

  const FeedbackFormWidget({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends State<FeedbackFormWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _jobTypeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleRating(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  void _submitForm() {
    final name = _nameController.text.trim();
    final jobType = _jobTypeController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty || _selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name and select a rating.'),
        ),
      );
      return;
    }

    widget.onSubmit(name, jobType, comment, _selectedRating);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          // Job Type Field
          TextField(
            controller: _jobTypeController,
            decoration: const InputDecoration(
              labelText: 'Job Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
          ),
          const SizedBox(height: 16),

          // Comment Field
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comments (Optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Star Rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () => _handleRating(index + 1),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit Feedback',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}