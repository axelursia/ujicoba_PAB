import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;

  const StarRating(
      {Key? key, required this.rating, required this.onRatingChanged})
      : super(key: key);

  Widget buildStar(int index) {
    if (index < rating) {
      return const Icon(Icons.star, color: Colors.amber);
    } else {
      return const Icon(Icons.star_border, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            onRatingChanged(index + 1);
          },
          child: buildStar(index),
        );
      }),
    );
  }
}
