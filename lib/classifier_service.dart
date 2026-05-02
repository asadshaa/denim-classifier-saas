import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  Interpreter? _interpreter;


  bool get isLoaded => _interpreter != null;

  Future<void> loadModel(String modelName) async {
    try {
      _interpreter?.close(); // Close existing if any
      
      // Determine if quantized based on name (simple heuristic as per requirements)
      
      final options = InterpreterOptions();
      // Add delegate options here if needed (e.g., GPUDelegate, NNAPIDelegate)
      // options.addDelegate(XNNPackDelegate()); 

      _interpreter = await Interpreter.fromAsset('assets/model/$modelName', options: options);
      debugPrint('Model $modelName loaded successfully.');
    } catch (e) {
      debugPrint('Failed to load model: $e');
      _interpreter = null;
    }
  }

  Future<List<double>> classifyImage(File imageFile) async {
    if (_interpreter == null) {
      throw Exception("Model not loaded");
    }

    // 1. Read image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // 2. Resize to 224x224
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // 3. Preprocess (Normalize)
    // Input tensor: [1, 224, 224, 3]
    var input = _preProcess(resizedImage);

    // 4. Run Inference
    // Output tensor: [1, 5]
    var output = List.generate(1, (index) => List.filled(5, 0.0));
    
    _interpreter!.run(input, output);

    // 5. Postprocess
    List<double> probabilities = List<double>.from(output[0]);
    return probabilities;
  }

  Object _preProcess(img.Image image) {
    // Creating a 4D array [1, 224, 224, 3]
    var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.generate(3, (c) => 0.0))));
    
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        
        // Normalize to [0, 1]
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }

  void close() {
    _interpreter?.close();
  }
}
