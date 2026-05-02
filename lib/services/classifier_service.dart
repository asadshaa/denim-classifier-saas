import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:denim_classifier/models/classification_result.dart';

/// Handles all TFLite model loading and inference.
///
/// Supports both:
///   • Legacy single-output models  → shape (1, N)
///   • Multi-head dual-output models → outputs[0]: (1, 21), outputs[1]: (1, 5)
class ClassifierService {
  Interpreter? _interpreter;
  bool _isMultiHead = false;

  bool get isLoaded => _interpreter != null;

  // ── Model Loading ───────────────────────────────────────────────────────────

  Future<void> loadModel(String modelName) async {
    try {
      _interpreter?.close();
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        'assets/model/$modelName',
        options: options,
      );

      // Auto-detect multi-head by checking number of output tensors
      final outputTensors = _interpreter!.getOutputTensors();
      _isMultiHead = outputTensors.length >= 2;

      debugPrint(
        'Model "$modelName" loaded. '
        'Multi-head: $_isMultiHead, '
        'Output tensors: ${outputTensors.length}',
      );
      
      for (int i = 0; i < outputTensors.length; i++) {
        debugPrint('Output $i: name=${outputTensors[i].name}, shape=${outputTensors[i].shape}, type=${outputTensors[i].type}');
      }
    } catch (e) {
      debugPrint('Failed to load model "$modelName": $e');
      _interpreter = null;
    }
  }

  // ── Inference ───────────────────────────────────────────────────────────────

  /// Classifies an image and returns a [ClassificationResult].
  /// Works for both legacy 5-class and new 21+5 multi-head models.
  Future<ClassificationResult> classifyImage(File imageFile) async {
    if (_interpreter == null) throw Exception('Model not loaded');

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Resize + normalize → [1, 224, 224, 3]
    final input = _preProcess(img.copyResize(image, width: 224, height: 224));

    final stopwatch = Stopwatch()..start();

    List<double> mainProbs;
    List<double> subProbs;

    if (_isMultiHead) {
      final tensors = _interpreter!.getOutputTensors();
      // Dynamically find which output index corresponds to which shape
      int mainIndex = tensors[0].shape.last == 21 ? 0 : (tensors.length > 1 ? 1 : 0);
      int subIndex  = tensors[0].shape.last == 5 ? 0 : (tensors.length > 1 ? 1 : 0);

      final outputMain = List.generate(1, (_) => List.filled(21, 0.0));
      final outputSub  = List.generate(1, (_) => List.filled(5, 0.0));
      final outputs = <int, Object>{
        mainIndex: outputMain,
        subIndex:  outputSub,
      };

      _interpreter!.runForMultipleInputs([input], outputs);
      mainProbs = List<double>.from(outputMain[0]);
      subProbs  = List<double>.from(outputSub[0]);
    } else {
      // Legacy single-output inference (5 classes) ---------------------------
      final output = [List.filled(5, 0.0)];
      _interpreter!.run(input, output);
      mainProbs = List<double>.from(output[0]);
      subProbs  = List.filled(5, 0.0); // no subclass in legacy model
    }

    stopwatch.stop();

    return ClassificationResult(
      mainProbabilities: mainProbs,
      subProbabilities: subProbs,
      inferenceMs: stopwatch.elapsedMilliseconds,
    );
  }

  // ── Pre-processing ──────────────────────────────────────────────────────────

  /// Converts an [img.Image] to a 4D float array [1, 224, 224, 3] normalized [0,1].
  List<List<List<List<double>>>> _preProcess(img.Image image) {
    return List.generate(1, (_) =>
      List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = image.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );
  }

  void close() => _interpreter?.close();
}
