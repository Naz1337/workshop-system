import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manage_rating/feedback_view_model.dart';

class FeedbackFormWidget extends StatelessWidget {
  const FeedbackFormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name Field
            _buildTextField(
              controller: viewModel.customerNameController,
              label: "Customer Name",
              icon: Icons.person_outline,
              isRequired: true,
              errorText: viewModel.getFieldError('customerName'),
            ),
            
            const SizedBox(height: 16),
            
            // Job Type Field
            _buildTextField(
              controller: viewModel.jobTypeController,
              label: "Job Type",
              icon: Icons.build_outlined,
              isRequired: true,
              errorText: viewModel.getFieldError('jobType'),
            ),
            
            const SizedBox(height: 16),
            
            // Comment Field
            _buildTextField(
              controller: viewModel.commentController,
              label: "Additional Comments",
              icon: Icons.chat_bubble_outline,
              isRequired: false,
              maxLines: 3,
              hint: "Tell us about your experience (optional)",
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isRequired,
    String? errorText,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? "Enter $label",
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}