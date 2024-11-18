import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:tflite/tflite.dart';

class PlantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> plant;

  PlantDetailsScreen({required this.plant});

  @override
  _PlantDetailsScreenState createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  List<Map<String, String>> videoDetails = [];
  List<VideoPlayerController> videoControllers = [];
  bool isLoadingVideos = true;
  int expandedIndex = -1;

  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTFLiteModel();
    _loadVideosFromFirebase();
  }

  // Load TFLite model
  Future<void> _loadTFLiteModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/plant_growth_stage_model.tflite",
      );
      print("Model loaded: $res");
    } catch (e) {
      print("Error loading TFLite model: $e");
    }
  }

  // Load video URLs from Firebase Storage dynamically based on plant name
  Future<void> _loadVideosFromFirebase() async {
    try {
      final plantName = widget.plant['name'].toLowerCase(); // Use plant name to determine folder
      final storageRef = FirebaseStorage.instance.ref().child('videos/$plantName');
      final ListResult result = await storageRef.listAll();

      // Fetch video URLs and sort them by filename
      List<Map<String, String>> videos = await Future.wait(result.items.map((ref) async {
        String url = await ref.getDownloadURL();
        return {
          'title': ref.name.split('.mp4')[0], // Use filename (without extension) as the title
          'url': url
        };
      }).toList());

      videos.sort((a, b) => a['title']!.compareTo(b['title']!)); // Sort videos by title

      setState(() {
        videoDetails = videos;
        isLoadingVideos = false;
      });

      // Initialize video controllers
      videoControllers = videos.map((video) => VideoPlayerController.network(video['url']!)).toList();
      for (var controller in videoControllers) {
        await controller.initialize();
      }
      setState(() {});
    } catch (e) {
      print("Error fetching videos from Firebase: $e");
      setState(() {
        isLoadingVideos = false;
      });
    }
  }

  // Analyze plant progress using TFLite
  Future<void> _analyzePlantProgress() async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: "path/to/your/image.jpg",
        numResults: 1,
        threshold: 0.5,
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        setState(() {
          progress = recognitions[0]['confidence'] * 100;
        });
      }
    } catch (e) {
      print("Error analyzing plant progress: $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    for (var controller in videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plant['name']} Details'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.plant['name'] ?? 'Unknown Plant',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            SizedBox(height: 10),
            Text(
              'Progress: ${(progress).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18, color: Colors.green.shade700),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _analyzePlantProgress();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Progress updated based on analysis!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Check Progress",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Tutorials',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800),
            ),
            SizedBox(height: 10),
            isLoadingVideos
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: videoDetails.length,
                      itemBuilder: (context, index) {
                        final video = videoDetails[index];
                        return ExpansionTile(
                          title: Text(video['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                          children: [
                            if (videoControllers[index].value.isInitialized)
                              AspectRatio(
                                aspectRatio: videoControllers[index].value.aspectRatio,
                                child: VideoPlayer(videoControllers[index]),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Initializing video...'),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.play_arrow, color: Colors.green),
                                  onPressed: () => videoControllers[index].play(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.pause, color: Colors.red),
                                  onPressed: () => videoControllers[index].pause(),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
