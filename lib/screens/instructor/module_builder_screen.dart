import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/course_service.dart';
import '../../models/module_model.dart';
import '../../models/course_model.dart';

class ModuleBuilderScreen extends StatefulWidget {
  final Course course;

  const ModuleBuilderScreen({super.key, required this.course});

  @override
  State<ModuleBuilderScreen> createState() => _ModuleBuilderScreenState();
}

class _ModuleBuilderScreenState extends State<ModuleBuilderScreen> {
  final _titleController = TextEditingController();

  void _addModule() async {
    if (_titleController.text.isEmpty) return;

    final courseService = Provider.of<CourseService>(context, listen: false);
    final module = Module(
      id: const Uuid().v4(),
      title: _titleController.text,
      order: 0, // Logic to determine order needed if strict ordering required
    );

    await courseService.addModule(widget.course.id, module);
    _titleController.clear();
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Module")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Module Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addModule,
              child: const Text("Create Module"),
            ),
          ],
        ),
      ),
    );
  }
}
