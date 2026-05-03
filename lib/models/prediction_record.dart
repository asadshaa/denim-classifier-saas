import 'package:hive/hive.dart';

part 'prediction_record.g.dart';

@HiveType(typeId: 0)
class PredictionRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String mainClass;

  @HiveField(3)
  final String subclass;

  @HiveField(4)
  final double confidenceMain;

  @HiveField(5)
  final double confidenceSub;

  @HiveField(6)
  final int inferenceTime;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  bool? isCorrect; // null = unverified, true = correct, false = incorrect

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  final List<double> mainProbabilities;

  @HiveField(11)
  final List<double> subProbabilities;

  PredictionRecord({
    required this.id,
    required this.imagePath,
    required this.mainClass,
    required this.subclass,
    required this.confidenceMain,
    required this.confidenceSub,
    required this.inferenceTime,
    required this.timestamp,
    this.isCorrect,
    this.isSynced = false,
    required this.mainProbabilities,
    required this.subProbabilities,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'main_class': mainClass,
      'subclass': subclass,
      'confidence_main': confidenceMain,
      'confidence_sub': confidenceSub,
      'inference_time': inferenceTime,
      'timestamp': timestamp.toIso8601String(),
      'is_correct': isCorrect,
      'device_type': 'mobile',
      'main_probs': mainProbabilities,
      'sub_probs': subProbabilities,
    };
  }
}
