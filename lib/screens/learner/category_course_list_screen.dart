import 'package:provider/provider.dart';
import '../../widgets/course_card.dart';
import '../../services/course_service.dart';
import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import '../../models/course_model.dart';
import 'course_detail_screen.dart';

class CategoryCourseListScreen extends StatefulWidget {
  final String category;
  const CategoryCourseListScreen({super.key, required this.category});

  @override
  State<CategoryCourseListScreen> createState() => _CategoryCourseListScreenState();
}

class _CategoryCourseListScreenState extends State<CategoryCourseListScreen> {
  RangeValues _priceRange = const RangeValues(0, 500);
  String _sortBy = 'relevance';

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Filters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   const Divider(),
                   const Text("Price Range"),
                   RangeSlider(
                     values: _priceRange,
                     min: 0,
                     max: 500,
                     divisions: 10,
                     labels: RangeLabels("\$${_priceRange.start.round()}", "\$${_priceRange.end.round()}"),
                     onChanged: (val) {
                       setModalState(() => _priceRange = val);
                     },
                   ),
                   const SizedBox(height: 16),
                   const Text("Sort By"),
                   Wrap(
                     spacing: 8,
                     children: [
                       ChoiceChip(
                         label: const Text("Relevance"),
                         selected: _sortBy == 'relevance',
                         onSelected: (b) => setModalState(() => _sortBy = 'relevance'),
                       ),
                       ChoiceChip(
                         label: const Text("Price: Low to High"),
                         selected: _sortBy == 'price_low',
                         onSelected: (b) => setModalState(() => _sortBy = 'price_low'),
                       ),
                        ChoiceChip(
                         label: const Text("Price: High to Low"),
                         selected: _sortBy == 'price_high',
                         onSelected: (b) => setModalState(() => _sortBy = 'price_high'),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () {
                         setState(() {}); // Trigger rebuild
                         Navigator.pop(context);
                       },
                       child: const Text("Apply Filters"),
                     ),
                   )
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseService = Provider.of<CourseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          )
        ],
      ),
      body: Consumer<CourseService>(
        builder: (context, courseService, child) {
          final courses = courseService.courses;
          
          var filtered = courses.where((c) {
             final matchesCategory = c.title.toLowerCase().contains(widget.category.toLowerCase());
             final matchesPrice = c.price >= _priceRange.start && c.price <= _priceRange.end;
             return matchesCategory && matchesPrice;
          }).toList();

          // Sorting
          if (_sortBy == 'price_low') {
            filtered.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortBy == 'price_high') {
            filtered.sort((a, b) => b.price.compareTo(a.price));
          }

          if (filtered.isEmpty) return const Center(child: Text("No courses in this category"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final course = filtered[index];
              return CourseCard(
                course: course,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
              );
            },
          );
        },
      ),
    );
  }
}
