import 'package:flutter/material.dart';

class RatingStars extends StatefulWidget {
  final int rating;
  final bool interactive;
  final Function(int)? onRatingChanged;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.interactive = false,
    this.onRatingChanged,
    this.size = 32,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.interactive
              ? () {
                  setState(() {
                    _currentRating = index + 1;
                    if (widget.onRatingChanged != null) {
                      widget.onRatingChanged!(_currentRating);
                    }
                  });
                }
              : null,
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: widget.size,
          ),
        );
      }),
    );
  }
}