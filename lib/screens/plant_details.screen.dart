import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class PlantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> plant;

  PlantDetailsScreen({required this.plant});

  @override
  _PlantDetailsScreenState createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  final List<Map<String, String>> tutorials = [
    {'title': 'Part 1: Getting Started', 'content': 'Learn the basics of plant care.'},
    {'title': 'Part 2: Watering Tips', 'content': 'How to water your plants effectively.'},
    {'title': 'Part 3: Sunlight Requirements', 'content': 'Understanding light needs for different plants.'},
    {'title': 'Part 4: Common Issues', 'content': 'Identifying and fixing common plant issues.'},
  ];

  List<bool> _isExpandedList = [false, false, false, false];
  double progress = 0.0; // Placeholder for TFLite progress result

  @override
  void initState() {
    super.initState();
    _loadTFLiteModel();
  }

  Future<void> _loadTFLiteModel() async {
    // Load the TFLite model
    String? res = await Tflite.loadModel(
      model: "assets/plant_growth_stage_model.tflite", // Replace with the path to your TFLite model
    );
    print("Model loaded: $res");
  }

  Future<void> _analyzePlantProgress() async {
    // Run the model on an image (or any data you have)
    var recognitions = await Tflite.runModelOnImage(
      path: "path/to/your/image.jpg", // Replace with the image path or data source
      numResults: 1,
      threshold: 0.5,
      asynch: true,
    );

    // Process the result to update progress (Assuming model outputs a single result)
    if (recognitions != null && recognitions.isNotEmpty) {
      setState(() {
        // Assuming the model output is a value between 0 and 1 representing progress
        progress = recognitions[0]['confidence'] * 100; // Convert to percentage
      });
    }
  }

  @override
  void dispose() {
    Tflite.close(); // Release resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Details'),
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
            Expanded(
              child: SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isExpandedList[index] = !isExpanded;
                    });
                  },
                  children: tutorials.asMap().entries.map<ExpansionPanel>((entry) {
                    int index = entry.key;
                    Map<String, String> tutorial = entry.value;
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(
                            tutorial['title']!,
                            style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          tutorial['content']!,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                      isExpanded: _isExpandedList[index],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
