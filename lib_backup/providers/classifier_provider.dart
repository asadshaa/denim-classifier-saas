import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denim_classifier/services/classifier_service.dart';

class ClassifierProvider with ChangeNotifier {
  final ClassifierService _classifierService = ClassifierService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  File? get image => _image;

  List<double>? _results;
  List<double>? get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedModel = 'best_model.tflite'; // Default
  String get selectedModel => _selectedModel;

  ClassifierProvider() {
    _loadModelPreference();
  }

  Future<void> _loadModelPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedModel = prefs.getString('selected_model') ?? 'best_model.tflite';
    await _loadModel();
  }

  Future<void> _loadModel() async {
    _isLoading = true;
    notifyListeners();
    await _classifierService.loadModel(_selectedModel);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setModel(String modelName) async {
    if (_selectedModel == modelName) return;
    _selectedModel = modelName;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_model', modelName);

    await _loadModel();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _results = null; // Reset results on new image
        notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> classifyImage() async {
    if (_image == null || !_classifierService.isLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _classifierService.classifyImage(_image!);
    } catch (e) {
      print("Error classifying image: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
