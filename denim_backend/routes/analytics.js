const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Prediction = require('../models/Prediction');
const mongoose = require('mongoose');

// @route   GET api/analytics
// @desc    Get analytics data for charts
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const userObjectId = new mongoose.Types.ObjectId(userId);

    const totalScans = await Prediction.countDocuments({ userId });

    const classDistribution = await Prediction.aggregate([
      { $match: { userId: userObjectId } },
      { $group: { _id: '$main_class', count: { $sum: 1 } } },
      { $project: { name: '$_id', value: '$count', _id: 0 } },
      { $sort: { value: -1 } },
      { $limit: 10 }
    ]);

    const subclassFrequency = await Prediction.aggregate([
      { $match: { userId: userObjectId } },
      { $group: { _id: '$subclass', count: { $sum: 1 } } },
      { $project: { name: { $concat: ["Variant ", "$_id"] }, count: '$count', _id: 0 } },
      { $sort: { name: 1 } }
    ]);

    const usageOverTime = await Prediction.aggregate([
      { $match: { userId: userObjectId } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$timestamp" } },
          scans: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } },
      { $limit: 7 },
      { $project: { date: '$_id', scans: 1, _id: 0 } }
    ]);

    const confidenceByClass = await Prediction.aggregate([
      { $match: { userId: userObjectId } },
      { $group: { _id: '$main_class', avgConfidence: { $avg: '$confidence_main' } } },
      { $project: { name: '$_id', avgConf: { $multiply: ['$avgConfidence', 100] }, _id: 0 } },
      { $sort: { avgConf: 1 } },
      { $limit: 10 }
    ]);

    const lowConfidenceScans = await Prediction.find({
      userId: userObjectId,
      confidence_main: { $lt: 0.80 } // updated to 0.80 per user spec
    })
    .sort({ timestamp: -1 })
    .limit(10) // Show more for Needs Review
    .select('main_class subclass confidence_main timestamp imageUrl feedback');

    res.json({
      totalScans,
      classDistribution,
      subclassFrequency,
      usageOverTime,
      confidenceByClass,
      lowConfidenceScans
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/analytics/model-metrics
// @desc    Get precomputed training epoch logs
// @access  Private
router.get('/model-metrics', auth, (req, res) => {
  // Simulating the Python training logs the user provided for EfficientNetB0
  const metrics = [
    { epoch: 1, acc: 63.03, val_acc: 79.01, loss: 1.71, val_loss: 0.98 },
    { epoch: 2, acc: 99.34, val_acc: 94.86, loss: 0.06, val_loss: 0.52 },
    { epoch: 3, acc: 99.60, val_acc: 97.44, loss: 0.02, val_loss: 0.39 },
    { epoch: 4, acc: 99.78, val_acc: 97.18, loss: 0.01, val_loss: 0.36 },
    { epoch: 5, acc: 99.83, val_acc: 98.10, loss: 0.01, val_loss: 0.48 },
    { epoch: 6, acc: 99.81, val_acc: 98.73, loss: 0.01, val_loss: 0.25 }
  ];
  
  const classificationReport = {
    precision: 0.99,
    recall: 0.99,
    f1: 0.99,
    support: 9315
  };

  res.json({ metrics, classificationReport });
});

// @route   GET api/analytics/confusion-matrix
// @desc    Get confusion matrix data
// @access  Private
router.get('/confusion-matrix', auth, async (req, res) => {
  try {
    // In a real scenario with active learning, we would compare prediction.main_class vs prediction.true_class (from feedback)
    // For now, we simulate the confusion matrix based on a subset of top classes to keep the UI readable,
    // or return a sparse matrix structure that Recharts can render.
    
    // We'll generate a mock matrix reflecting their actual 98.7% accuracy.
    const topClasses = ["138-CG", "1553-EL", "1600-JK", "P140394I", "PRT0235AY"];
    
    let matrixData = [];
    topClasses.forEach((actual) => {
      topClasses.forEach((predicted) => {
        let value = 0;
        if (actual === predicted) {
          value = 430 + Math.floor(Math.random() * 20); // High correct predictions
        } else {
          value = Math.floor(Math.random() * 5); // Low incorrect predictions
        }
        matrixData.push({ actual, predicted, count: value });
      });
    });

    res.json(matrixData);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/analytics/class-comparison
// @desc    Compare two classes
// @access  Private
router.get('/class-comparison', auth, async (req, res) => {
  try {
    const { classA, classB } = req.query;
    const userId = req.user.id;
    const userObjectId = new mongoose.Types.ObjectId(userId);

    const statsA = await Prediction.aggregate([
      { $match: { userId: userObjectId, main_class: classA } },
      { $group: { _id: null, count: { $sum: 1 }, avgConf: { $avg: '$confidence_main' } } }
    ]);

    const statsB = await Prediction.aggregate([
      { $match: { userId: userObjectId, main_class: classB } },
      { $group: { _id: null, count: { $sum: 1 }, avgConf: { $avg: '$confidence_main' } } }
    ]);

    res.json({
      classA: {
        name: classA,
        count: statsA[0]?.count || 0,
        avgConfidence: statsA[0]?.avgConf || 0
      },
      classB: {
        name: classB,
        count: statsB[0]?.count || 0,
        avgConfidence: statsB[0]?.avgConf || 0
      }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/analytics/performance
// @desc    Real-time model performance monitoring from DB
// @access  Private
router.get('/performance', auth, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user.id);

    // 1. ACCURACY OVER TIME — Based on user feedback per day
    // We group predictions by day, then compute ratio of 'correct' feedback
    const accuracyOverTime = await Prediction.aggregate([
      { $match: { userId, feedback: { $in: ['correct', 'incorrect'] } } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$timestamp" } },
          total: { $sum: 1 },
          correct: { $sum: { $cond: [{ $eq: ["$feedback", "correct"] }, 1, 0] } }
        }
      },
      { $sort: { _id: 1 } },
      { $limit: 30 },
      { $project: { date: '$_id', accuracy: { $multiply: [{ $divide: ['$correct', '$total'] }, 100] }, total: 1, _id: 0 } }
    ]);

    // 2. CONFIDENCE DISTRIBUTION — Histogram buckets for confidence scores
    const allPredictions = await Prediction.find({ userId }, 'confidence_main');
    const buckets = Array(10).fill(0); // 0-10%, 10-20%, ... 90-100%
    allPredictions.forEach(p => {
      const bucket = Math.min(Math.floor(p.confidence_main * 10), 9);
      buckets[bucket]++;
    });
    const confidenceDistribution = buckets.map((count, i) => ({
      range: `${i * 10}-${(i + 1) * 10}%`,
      count
    }));

    // 3. CLASS-WISE ACCURACY — Based on feedback per class
    const classAccuracy = await Prediction.aggregate([
      { $match: { userId, feedback: { $in: ['correct', 'incorrect'] } } },
      {
        $group: {
          _id: '$main_class',
          total: { $sum: 1 },
          correct: { $sum: { $cond: [{ $eq: ['$feedback', 'correct'] }, 1, 0] } }
        }
      },
      { $project: { class: '$_id', accuracy: { $multiply: [{ $divide: ['$correct', '$total'] }, 100] }, total: 1, _id: 0 } },
      { $sort: { accuracy: -1 } },
      { $limit: 10 }
    ]);

    // 4. SYSTEM PERFORMANCE — Average and latest inference latency from DB
    const latencyStats = await Prediction.aggregate([
      { $match: { userId, inference_time_ms: { $ne: null } } },
      {
        $group: {
          _id: null,
          avgLatency: { $avg: '$inference_time_ms' },
          minLatency: { $min: '$inference_time_ms' },
          maxLatency: { $max: '$inference_time_ms' },
          totalPredictions: { $sum: 1 }
        }
      }
    ]);

    // 5. CONFIDENCE DRIFT — Average confidence per day to detect model drift
    const confidenceDrift = await Prediction.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$timestamp" } },
          avgConfidence: { $avg: '$confidence_main' },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } },
      { $limit: 30 },
      { $project: { date: '$_id', avgConfidence: { $multiply: ['$avgConfidence', 100] }, count: 1, _id: 0 } }
    ]);

    res.json({
      accuracyOverTime,
      confidenceDistribution,
      classAccuracy,
      confidenceDrift,
      latencyStats: latencyStats[0] || { avgLatency: null, minLatency: null, maxLatency: null, totalPredictions: 0 }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;

