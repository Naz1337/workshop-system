import 'package:flutter/material.dart';

class RatingStarWidget extends StatelessWidget {
  final int rating;
  final Function(int)? onRatingSelected;
  final Color filledColor;
  final Color unfilledColor;
  final double size;

  const RatingStarWidget({
    super.key,
    required this.rating,
    this.onRatingSelected,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
    this.size = 40.0,
  });

  Widget _buildStar(int index) {
    IconData icon;
    Color color;
    
    if (index < rating) {
      icon = Icons.star;
      color = filledColor;
    } else {
      icon = Icons.star_border;
      color = unfilledColor;
    }

    return Icon(icon, color: color, size: size);
  }

  void _onStarTap(int starIndex) {
    if (onRatingSelected != null) {
      onRatingSelected!(starIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: onRatingSelected != null ? () => _onStarTap(starIndex) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildStar(index),
          ),
        );
      }),
    );
  }
}