import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool isHorizontal; // To switch between horizontal list item and vertical list item styles

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Width for horizontal scroll items, otherwise full width
    final width = isHorizontal ? 280.0 : double.infinity; 

    return Container(
      width: width,
      margin: EdgeInsets.only(right: isHorizontal ? 16 : 0, bottom: isHorizontal ? 0 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Section
              Stack(
                children: [
                   ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: course.thumbnailUrl.isNotEmpty
                          ? (course.thumbnailUrl.startsWith('http')
                              ? Image.network(
                                  course.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(color: Colors.grey[300], child: const Icon(Icons.error)),
                                )
                              : Image.file(
                                  dart_io.File(course.thumbnailUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(color: Colors.grey[300], child: const Icon(Icons.error)),
                                ))
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                    ),
                  ),
                  // Optional: Add a "Best Seller" or "New" badge here based on logic
                ],
              ),
             
              // Info Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Instructor Info (Mock Avatar)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            course.instructorName.isNotEmpty ? course.instructorName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            course.instructorName,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Metadata Row
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          course.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${100 + course.title.length})", // Mock review count for now
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          "\$${course.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
