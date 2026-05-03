import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:denim_classifier/services/analytics_service.dart';
import 'package:denim_classifier/models/prediction_record.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();
  late final Box<PredictionRecord> _box;

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnalyticsProvider() {
    _init();
  }

  void _init() {
    _box = Hive.box<PredictionRecord>('predictions');

    // Refresh immediately with whatever is in the box
    refresh();

    // Watch for any new records added by ClassifierProvider and auto-refresh
    _box.watch().listen((_) {
      refresh();
    });
  }

  void refresh() {
    _isLoading = true;
    notifyListeners();

    _stats = _service.calculateLocalAnalytics();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFeedback(PredictionRecord record, bool? isCorrect) async {
    record.isCorrect = isCorrect;
    await record.save(); // Hive watcher will auto-trigger refresh()
  }

  // Smart Alert Logic
  bool get hasLowConfidenceAlert {
    if (_stats['avgConfidence'] == null) return false;
    return (_stats['avgConfidence'] as double) < 80.0;
  }
}

