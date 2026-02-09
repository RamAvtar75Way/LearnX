import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/course_service.dart';
import '../../models/lesson_model.dart';
import '../../models/module_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class LessonBuilderScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const LessonBuilderScreen({super.key, required this.courseId, required this.moduleId});

  @override
  State<LessonBuilderScreen> createState() => _LessonBuilderScreenState();
}

class _LessonBuilderScreenState extends State<LessonBuilderScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedType = 'video'; // video, text, image, document
  String? _pickedFilePath;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    String? path;
    
    if (_selectedType == 'image') {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      path = image?.path;
    } else if (_selectedType == 'video') {
       final XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
       path = video?.path;
    } else if (_selectedType == 'document') {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );
      path = result?.files.single.path;
    }

    if (path != null) {
      setState(() {
        _pickedFilePath = path;
        _contentController.text = path!; // Auto-fill content with path
      });
    }
  }


  // ... (inside class)

  void _addLesson() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
        return;
    }

    String finalContentUrl = _contentController.text;

    // Check if it's a local file path that needs to be persisted
    if (_pickedFilePath != null && finalContentUrl == _pickedFilePath) {
       try {
         final directory = await getApplicationDocumentsDirectory();
         final fileName = "${const Uuid().v4()}_${_pickedFilePath!.split('/').last}";
         final savedFile = await File(_pickedFilePath!).copy('${directory.path}/$fileName');
         finalContentUrl = savedFile.path;
       } catch (e) {
         debugPrint("Error saving file: $e");
         // Fallback to original path if copy fails, though unlikely
       }
    }

    final courseService = Provider.of<CourseService>(context, listen: false);
    final lesson = Lesson(
      id: const Uuid().v4(),
      title: _titleController.text,
      contentUrl: finalContentUrl,
      type: _selectedType,
      durationSeconds: (int.tryParse(_durationController.text) ?? 0) * 60,
    );

    await courseService.addLesson(widget.courseId, widget.moduleId, lesson);
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Lesson")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Lesson Title", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'video', child: Text("Video")),
                DropdownMenuItem(value: 'text', child: Text("Text Content")),
                DropdownMenuItem(value: 'image', child: Text("Image")),
                 DropdownMenuItem(value: 'document', child: Text("Document")),
              ],
              onChanged: (val) => setState(() {
                _selectedType = val!;
                _pickedFilePath = null;
                _contentController.clear();
              }),
              decoration: const InputDecoration(labelText: "Content Type", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
             
             if (_selectedType != 'text')
               Column(
                 children: [
                   Row(
                     children: [
                       Expanded(
                         child: TextField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: _selectedType == 'video' ? "Video URL or Path" : (_selectedType == 'image' ? "Image URL or Path" : "Document Path"),
                            border: const OutlineInputBorder(),
                          ),
                         ),
                       ),
                       const SizedBox(width: 8),
                       IconButton(
                         onPressed: _pickFile, 
                         icon: const Icon(Icons.attach_file),
                         tooltip: "Pick File",
                       ),
                     ],
                   ),
                   if (_pickedFilePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Selected: ${_pickedFilePath!.split('/').last}", style: const TextStyle(color: Colors.green)),
                      ),
                 ],
               )
             else
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content Body",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),

            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Duration (minutes)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addLesson,
                child: const Text("Add Lesson"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
