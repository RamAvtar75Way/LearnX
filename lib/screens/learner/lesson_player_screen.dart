import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/lesson_model.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonPlayerScreen({super.key, required this.lesson});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = []; // Mock local notes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.lesson.type == 'video' && widget.lesson.contentUrl.isNotEmpty) {
      _initializeVideo();
    }
  }

  String? _errorMessage;

  Future<void> _initializeVideo() async {
    try {
      final url = widget.lesson.contentUrl;
      if (url.startsWith('http')) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        final file = dart_io.File(url);
        if (!await file.exists()) {
          setState(() {
            _errorMessage = "Video file not found. It may have been deleted or moved.";
          });
          return;
        }
        _videoPlayerController = VideoPlayerController.file(file);
      }

      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
        },
      );
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing video: $e");
      setState(() {
        _errorMessage = "Error loading video: $e";
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_noteController.text.trim().isNotEmpty) {
      setState(() {
        _notes.add(_noteController.text.trim());
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note saved locally")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          Consumer<CourseService>(
            builder: (context, courseService, child) {
              final authService = Provider.of<AuthService>(context, listen: false);
              final userId = authService.userModel?.uid;
              
              if (userId == null) return const SizedBox.shrink();

              final isDownloaded = courseService.isLessonDownloaded(userId, widget.lesson.id);
              return IconButton(
                icon: Icon(isDownloaded ? Icons.download_done : Icons.download_for_offline_outlined),
                tooltip: isDownloaded ? "Remove Download" : "Download for Offline",
                color: isDownloaded ? Colors.green : null,
                onPressed: () async {
                   await courseService.toggleLessonDownload(userId, widget.lesson.id);
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).hideCurrentSnackBar();
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(isDownloaded ? "Removed from downloads" : "Downloaded for offline use"))
                     );
                   }
                },
              );
            },
          )
        ],
      ),

      body: Column(
        children: [
          // Player Area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: widget.lesson.type == 'video'
                ? (_errorMessage != null 
                    ? Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                      )
                    : (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                        ? Chewie(controller: _chewieController!)
                        : const Center(child: CircularProgressIndicator())))
                : widget.lesson.type == 'image'
                    ? (widget.lesson.contentUrl.startsWith('http') 
                        ? Image.network(widget.lesson.contentUrl, fit: BoxFit.contain)
                        : Image.file(dart_io.File(widget.lesson.contentUrl), fit: BoxFit.contain, errorBuilder: (c,e,s) => const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.broken_image, size: 50), Text("Image not found")]))
                      )
                    : Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.description, size: 60, color: Colors.blue),
                            const SizedBox(height: 16),
                            Text("Document: ${widget.lesson.title}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (widget.lesson.contentUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Text(widget.lesson.contentUrl.split('/').last, textAlign: TextAlign.center),
                                ),
                            const SizedBox(height: 16),
                             ElevatedButton.icon(
                               onPressed: () {
                                 // Open document logic (e.g., using open_file package)
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document viewer not implemented yet")));
                               }, 
                               icon: const Icon(Icons.open_in_new),
                               label: const Text("Open Document"),
                             ),
                          ],
                        ),
                      ),
          ),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Notes"),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(widget.lesson.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       Text("Duration: ${widget.lesson.durationSeconds ~/ 60} mins", style: TextStyle(color: Colors.grey[600])),
                       const SizedBox(height: 16),
                       const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       const Text("This is a placeholder description for the lesson. In a real app, this would come from the backend."),
                    ],
                  ),
                ),
                
                // Notes Tab
                Column(
                  children: [
                    Expanded(
                      child: _notes.isEmpty 
                        ? const Center(child: Text("No notes yet. Add one below!"))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _notes.length,
                            separatorBuilder: (c, i) => const Divider(),
                            itemBuilder: (context, index) => ListTile(
                              leading: const Icon(Icons.note, color: Colors.amber),
                              title: Text(_notes[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                onPressed: () => setState(() => _notes.removeAt(index)),
                              ),
                            ),
                          ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                hintText: "Add a note...",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _saveNote,
                            icon: const Icon(Icons.send),
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
