import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as dart_io;
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../models/module_model.dart';
import '../../models/lesson_model.dart';
import 'module_builder_screen.dart';
import 'lesson_builder_screen.dart'; // Ensure these are imported

class EditCourseScreen extends StatefulWidget {
  final Course course;
  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _customCategoryController = TextEditingController();
  
  final List<String> _categories = [
    'Development',
    'Business',
    'Finance',
    'IT & Software',
    'Office Productivity',
    'Personal Development',
    'Design',
    'Marketing',
    'Lifestyle',
    'Photography & Video',
    'Health & Fitness',
    'Music',
    'Teaching & Academics',
    'Other'
  ];
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _titleController.text = widget.course.title;
    _descriptionController.text = widget.course.description;
    _priceController.text = widget.course.price.toString();
    
    // Initialize Category
    if (_categories.contains(widget.course.category)) {
      _selectedCategory = widget.course.category;
    } else {
      _selectedCategory = 'Other';
      _customCategoryController.text = widget.course.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  String? _pickedThumbnailPath;

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedThumbnailPath = image.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) return;

    String finalCategory = _selectedCategory == 'Other' 
        ? _customCategoryController.text.trim() 
        : _selectedCategory ?? '';
        
    if (finalCategory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category")));
        return;
    }

    final updatedCourse = widget.course.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      category: finalCategory, // Save Category
      price: double.tryParse(_priceController.text) ?? widget.course.price,
      thumbnailUrl: _pickedThumbnailPath ?? widget.course.thumbnailUrl,
    );

    final courseService = Provider.of<CourseService>(context, listen: false);
    await courseService.updateCourse(updatedCourse);
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course updated")));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final courseService = Provider.of<CourseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Course"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Save Changes",
            onPressed: _saveChanges,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Details Section
            const Text("Course Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Course Title", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCategory = val);
              },
            ),
            
            if (_selectedCategory == 'Other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customCategoryController,
                  decoration: const InputDecoration(
                  labelText: 'Custom Category', 
                  border: OutlineInputBorder()
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Price (\$)", border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            
            // Thumbnail Picker
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.grey),
                ),
                child: _pickedThumbnailPath != null
                    ? Image.file(dart_io.File(_pickedThumbnailPath!), fit: BoxFit.cover)
                    : (widget.course.thumbnailUrl.isNotEmpty
                        ? (widget.course.thumbnailUrl.startsWith('http') 
                            ? Image.network(widget.course.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.image))
                            : Image.file(dart_io.File(widget.course.thumbnailUrl), fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.image)))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.add_a_photo, size: 40), Text("Change Thumbnail")],
                          )
                      ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Modules Section
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Curriculum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Module"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ModuleBuilderScreen(course: widget.course)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            Consumer<CourseService>(
              builder: (context, courseService, child) {
                final modules = courseService.getModules(widget.course.id);
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(module.title),
                        children: [
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                             child: Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon( 
                                  icon: const Icon(Icons.add_circle, size: 16),
                                  label: const Text("Add Lesson"),
                                  onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LessonBuilderScreen(courseId: widget.course.id, moduleId: module.id),
                                        ),
                                      );
                                  },
                                ),
                             ),
                           ),
                           // Lessons List
                           Builder(
                             builder: (context) {
                               final lessons = courseService.getLessons(widget.course.id, module.id);
                               return Column(
                                 children: lessons.map((lesson) => ListTile(
                                   title: Text(lesson.title),
                                   subtitle: Text(lesson.type.toUpperCase()),
                                   leading: Icon(
                                     lesson.type == 'video' ? Icons.play_circle 
                                     : lesson.type == 'image' ? Icons.image 
                                     : Icons.description
                                   ),
                                   trailing: IconButton(
                                     icon: const Icon(Icons.edit, size: 16),
                                     onPressed: () {
                                       // Edit lesson Todo
                                     },
                                   ),
                                 )).toList(),
                               );
                             }
                           )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Delete Course"),
                  onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context, 
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Course"),
                          content: const Text("Are you sure? This cannot be undone."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        )
                      );

                      if (confirm == true && mounted) {
                        final courseService = Provider.of<CourseService>(context, listen: false);
                        await courseService.deleteCourse(widget.course.id); 
                        if(mounted) {
                          Navigator.pop(context); // Pop Edit Screen
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course deleted")));
                        }
                      }
                  },
                ),
            ),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
