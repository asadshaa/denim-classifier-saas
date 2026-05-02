import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:denim_classifier/utils/fabric_data.dart';

class ResultsScreen extends StatelessWidget {
  final List<double> probabilities;
  final String imagePath; // Optionally show the image again

  const ResultsScreen({super.key, required this.probabilities, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Pair probs with labels
    List<MapEntry<String, double>> results = [];
    for (int i = 0; i < probabilities.length; i++) {
      if (i < FabricData.classes.length) {
        results.add(MapEntry(FabricData.classes[i], probabilities[i]));
      }
    }

    // Sort by confidence descending
    results.sort((a, b) => b.value.compareTo(a.value));

    final topClass = results.first.key;
    final topConfidence = results.first.value;
    final description = FabricData.classesEng[topClass] ?? "Unknown Fabric";
    final characteristics = FabricData.classesChar[topClass] ?? "No details available";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification Results'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Confidence Meter
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              percent: topConfidence,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(topConfidence * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                  ),
                  Text(topClass, style: const TextStyle(fontSize: 16.0)),
                ],
              ),
              progressColor: _getColor(topConfidence),
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
            const SizedBox(height: 20),
            
            // Top Prediction Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      topClass,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 30),
                    Text(
                      characteristics,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // All Results
            const Text(
              "Confidences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final confidence = item.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text("${(confidence * 100).toStringAsFixed(1)}%"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearPercentIndicator(
                        lineHeight: 14.0,
                        percent: confidence,
                        backgroundColor: Colors.grey.shade200,
                        progressColor: _getColor(confidence),
                        barRadius: const Radius.circular(7),
                        animation: true,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            
            // Share Button
            ElevatedButton.icon(
              onPressed: () {
                final text = "Denim Classification Results:\nTop Match: $topClass (${(topConfidence * 100).toStringAsFixed(1)}%)\nDetails: $description";
                Share.share(text);
              },
              icon: const Icon(Icons.share),
              label: const Text("Share Results"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(double confidence) {
    if (confidence > 0.7) return Colors.green;
    if (confidence > 0.4) return Colors.orangeAccent; // Used "Yellow" (>40%) in prompt but standard yellow is invisible on white
    return Colors.deepOrange; // "<40%"
  }
}
