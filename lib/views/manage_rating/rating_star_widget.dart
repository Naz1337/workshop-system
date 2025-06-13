import 'package:flutter/material.dart';

class RatingStarWidget extends StatefulWidget {
  final int rating;
  final double size;
  final bool isInteractive;
  final Function(int)? onRatingSelected;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStarWidget({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.isInteractive = true,
    this.onRatingSelected,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  State<RatingStarWidget> createState() => _RatingStarWidgetState();
}

class _RatingStarWidgetState extends State<RatingStarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _hoveredStar = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int starNumber) {
    if (widget.onRatingSelected != null) {
      widget.onRatingSelected!(starNumber);
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isActive = starNumber <= widget.rating;
        final isHovered = widget.isInteractive && starNumber <= _hoveredStar;
        
        return GestureDetector(
          onTap: widget.isInteractive ? () => _handleTap(starNumber) : null,
          onTapDown: widget.isInteractive
              ? (_) => setState(() {
                    _hoveredStar = starNumber;
                  })
              : null,
          onTapCancel: widget.isInteractive
              ? () => setState(() {
                    _hoveredStar = 0;
                  })
              : null,
          child: MouseRegion(
            onEnter: widget.isInteractive
                ? (_) => setState(() {
                      _hoveredStar = starNumber;
                    })
                : null,
            onExit: widget.isInteractive
                ? (_) => setState(() {
                      _hoveredStar = 0;
                    })
                : null,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                final scale = starNumber <= widget.rating ? _scaleAnimation.value : 1.0;
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.all(widget.size * 0.1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        (isActive || isHovered)
                          ? Icons.star
                          : Icons.star_border,
                      size: widget.size,
                      color: (isActive || isHovered)
                          ? widget.activeColor
                          : widget.inactiveColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}