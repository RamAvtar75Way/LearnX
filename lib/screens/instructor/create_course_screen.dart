import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
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
  final _customCategoryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  double _price = 0.0;
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      String finalCategory = _selectedCategory == 'Other' 
        ? _customCategoryController.text.trim() 
        : _selectedCategory ?? '';
        
      if (finalCategory.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select or enter a category")));
         return;
      }

      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final courseService = Provider.of<CourseService>(context, listen: false);
      final user = authService.userModel;

      if (user == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found")));
        return;
      }

      final newCourse = Course(
        id: const Uuid().v4(),
        title: _title,
        description: _description,
        category: finalCategory,
        price: _price,
        thumbnailUrl: _imageFile?.path ?? 'https://picsum.photos/800/600', 
        instructorId: user.uid,
        instructorName: user.name,
        ratingAvg: 0.0, // Default for new course
      );

      String? error = await courseService.createCourse(newCourse);

      setState(() => _isLoading = false);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course created successfully!")));
        _formKey.currentState!.reset();
        _customCategoryController.clear();
        setState(() {
          _title = '';
          _description = '';
          _selectedCategory = null;
          _price = 0.0;
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _imageFile != null 
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Tap to upload thumbnail", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                onSaved: (val) => _description = val!,
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val);
                },
                validator: (val) => val == null ? 'Select a category' : null,
              ),
              
              // Custom Category Input (Visible only if 'Other' is selected)
              if (_selectedCategory == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Custom Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  validator: (val) {
                    if (_selectedCategory == 'Other' && (val == null || val.isEmpty)) {
                      return 'Please enter your custom category';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'USD',
                ),
                keyboardType: TextInputType.number,
                 validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter price';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
                onSaved: (val) => _price = double.parse(val!),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Create Course'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
