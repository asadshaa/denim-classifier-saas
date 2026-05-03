import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denim_classifier/services/classifier_service.dart';
import 'package:denim_classifier/models/classification_result.dart';
import 'package:denim_classifier/models/prediction_record.dart';
import 'package:uuid/uuid.dart';

class ClassifierProvider with ChangeNotifier {
  final ClassifierService _classifierService = ClassifierService();
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  File? _image;
  File? get image => _image;

  ClassificationResult? _result;
  ClassificationResult? get result => _result;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  String _selectedModel = 'denim_model.tflite'; 
  String get selectedModel => _selectedModel;

  ClassifierProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadModelPreference();
  }

  Future<void> _loadModelPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedModel = prefs.getString('selected_model') ?? 'denim_model.tflite';
    await _loadModel();
    notifyListeners();
  }

  Future<void> _loadModel() async {
    await _classifierService.loadModel(_selectedModel);
  }

  Future<void> setModel(String modelPath) async {
    if (_selectedModel == modelPath) return;
    _selectedModel = modelPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_model', modelPath);

    _isLoading = true;
    notifyListeners();

    await _loadModel();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _result = null;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> classifyImage() async {
    if (_image == null || !_classifierService.isLoaded) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _result = await _classifierService.classifyImage(_image!);

      if (_result != null) {
        await _saveToHistory(_result!);
      }
    } catch (e, st) {
      debugPrint('CLASSIFY ERROR: $e\n$st');
      _lastError = e.toString();
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToHistory(ClassificationResult result) async {
    try {
      final box = Hive.box<PredictionRecord>('predictions');
      
      final record = PredictionRecord(
        id: _uuid.v4(),
        imagePath: _image?.path ?? '',
        mainClass: result.topMainClass,
        subclass: result.topSubclass,
        confidenceMain: result.topMainConfidence,
        confidenceSub: result.topSubConfidence,
        inferenceTime: result.inferenceMs,
        timestamp: DateTime.now(),
        mainProbabilities: result.mainProbabilities,
        subProbabilities: result.subProbabilities,
      );

      await box.add(record);
      debugPrint('Saved to Hive: ${record.mainClass}');
    } catch (e) {
      debugPrint('Hive Save Error: $e');
    }
  }
}
