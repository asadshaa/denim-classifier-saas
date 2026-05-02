import 'package:denim_classifier/utils/fabric_taxonomy.dart';

/// Typed result from a dual-output multi-head classification.
/// Output 0 → main class (21 classes)
/// Output 1 → subclass  (5 classes)
class ClassificationResult {
  /// Raw softmax probabilities for all 21 main classes.
  final List<double> mainProbabilities;

  /// Raw softmax probabilities for all 5 subclasses.
  final List<double> subProbabilities;

  /// Wall-clock inference time in milliseconds.
  final int inferenceMs;

  const ClassificationResult({
    required this.mainProbabilities,
    required this.subProbabilities,
    required this.inferenceMs,
  });

  // ── Derived properties ──────────────────────────────────────────────────────

  /// Index of the highest-confidence main class.
  int get topMainIndex {
    int idx = 0;
    for (int i = 1; i < mainProbabilities.length; i++) {
      if (mainProbabilities[i] > mainProbabilities[idx]) idx = i;
    }
    return idx;
  }

  /// Name of the top main class.
  String get topMainClass =>
      topMainIndex < FabricTaxonomy.mainClasses.length
          ? FabricTaxonomy.mainClasses[topMainIndex]
          : 'Unknown';

  /// Confidence of the top main class (0–1).
  double get topMainConfidence => mainProbabilities.isEmpty
      ? 0
      : mainProbabilities[topMainIndex];

  /// Index of the highest-confidence subclass.
  int get topSubIndex {
    int idx = 0;
    for (int i = 1; i < subProbabilities.length; i++) {
      if (subProbabilities[i] > subProbabilities[idx]) idx = i;
    }
    return idx;
  }

  /// Label of the top subclass (e.g. "Variant A").
  String get topSubclass => FabricTaxonomy.subclassFor(topSubIndex);

  /// Confidence of the top subclass (0–1).
  double get topSubConfidence =>
      subProbabilities.isEmpty ? 0 : subProbabilities[topSubIndex];

  /// Top N main class predictions sorted by confidence descending.
  List<({String label, double confidence, int index})> topN(int n) {
    final entries = List.generate(
      mainProbabilities.length,
      (i) => (
        label: i < FabricTaxonomy.mainClasses.length
            ? FabricTaxonomy.mainClasses[i]
            : 'CLASS-$i',
        confidence: mainProbabilities[i],
        index: i,
      ),
    );
    entries.sort((a, b) => b.confidence.compareTo(a.confidence));
    return entries.take(n).toList();
  }

  /// Combined confidence: geometric mean of main & subclass top scores.
  double get combinedConfidence =>
      (topMainConfidence * topSubConfidence) > 0
          ? (topMainConfidence + topSubConfidence) / 2
          : topMainConfidence;

  /// Serialize to JSON-friendly map (for SharedPreferences history).
  Map<String, dynamic> toJson() => {
        'mainClass': topMainClass,
        'mainConfidence': topMainConfidence,
        'subclass': topSubclass,
        'subConfidence': topSubConfidence,
        'mainIndex': topMainIndex,
        'subIndex': topSubIndex,
        'inferenceMs': inferenceMs,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
}
