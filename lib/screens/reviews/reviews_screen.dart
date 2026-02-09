import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import 'package:intl/intl.dart';

class CourseReviewsScreen extends StatelessWidget {
  final List<Review> reviews;

  const CourseReviewsScreen({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Reviews")),
      body: reviews.isEmpty 
          ? const Center(child: Text("No reviews yet."))
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(child: Text(review.userName[0])),
                            const SizedBox(width: 8),
                            Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text(DateFormat.yMMMd().format(review.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          )),
                        ),
                        const SizedBox(height: 8),
                         Text(review.comment),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
