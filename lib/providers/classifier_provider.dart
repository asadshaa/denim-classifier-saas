import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denim_classifier/services/classifier_service.dart';
import 'package:denim_classifier/models/classification_result.dart';
import 'dart:convert';

class ClassifierProvider with ChangeNotifier {
  final ClassifierService _classifierService = ClassifierService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  File? get image => _image;

  ClassificationResult? _result;
  ClassificationResult? get result => _result;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  String _selectedModel = 'denim_model.tflite'; // Default to new multi-head model
  String get selectedModel => _selectedModel;

  ClassifierProvider() {
    _loadModelPreference();
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

      // Persist to scan history
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
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('scan_history_json') ?? '[]';
      final List<dynamic> list = jsonDecode(jsonStr);
      list.add(result.toJson());
      // Keep latest 200 entries
      final trimmed = list.length > 200 ? list.sublist(list.length - 200) : list;
      await prefs.setString('scan_history_json', jsonEncode(trimmed));
    } catch (_) {}
  }
}
