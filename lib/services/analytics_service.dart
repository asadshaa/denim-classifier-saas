import 'package:hive/hive.dart';
import 'package:denim_classifier/models/prediction_record.dart';

class AnalyticsService {
  final Box<PredictionRecord> _box = Hive.box<PredictionRecord>('predictions');

  Map<String, dynamic> calculateLocalAnalytics() {
    final records = _box.values.toList();
    if (records.isEmpty) return {};

    double totalConfidence = 0;
    int totalInferenceTime = 0;
    Map<String, int> classCounts = {};
    Map<String, int> subclassCounts = {};
    int correctCount = 0;
    int incorrectCount = 0;

    for (var r in records) {
      totalConfidence += r.confidenceMain;
      totalInferenceTime += r.inferenceTime;
      classCounts[r.mainClass] = (classCounts[r.mainClass] ?? 0) + 1;
      subclassCounts[r.subclass] = (subclassCounts[r.subclass] ?? 0) + 1;
      
      if (r.isCorrect == true) correctCount++;
      if (r.isCorrect == false) incorrectCount++;
    }

    final mostPredictedClass = classCounts.entries.isEmpty 
        ? 'N/A' 
        : classCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final feedbackCount = correctCount + incorrectCount;
    final accuracy = feedbackCount > 0 ? (correctCount / feedbackCount) * 100 : 0.0;

    return {
      'totalScans': records.length,
      'avgConfidence': (totalConfidence / records.length) * 100,
      'avgInferenceMs': totalInferenceTime / records.length,
      'mostPredictedClass': mostPredictedClass,
      'accuracy': accuracy,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'classDistribution': classCounts,
      'subclassDistribution': subclassCounts,
      'recentPredictions': records.reversed.take(20).toList(),
    };
  }
}
