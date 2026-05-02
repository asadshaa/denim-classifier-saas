const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Prediction = require('../models/Prediction');
const mongoose = require('mongoose');

// @route   GET api/dataset
// @desc    Get all predictions with pagination and filtering
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, main_class, feedback, low_confidence } = req.query;
    const userId = new mongoose.Types.ObjectId(req.user.id);
    
    let query = { userId };

    if (main_class) {
      query.main_class = main_class;
    }

    if (feedback) {
      query.feedback = feedback;
    }

    if (low_confidence === 'true') {
      // Threshold can be pulled from query or set to default
      const threshold = req.query.threshold ? parseFloat(req.query.threshold) : 0.80;
      query.confidence_main = { $lt: threshold };
    }

    const predictions = await Prediction.find(query)
      .sort({ timestamp: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('imageUrl main_class subclass confidence_main feedback timestamp inference_time_ms model_version');

    const count = await Prediction.countDocuments(query);

    res.json({
      predictions,
      totalPages: Math.ceil(count / limit),
      currentPage: parseInt(page),
      totalItems: count
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/dataset/classes
// @desc    Get unique classes in dataset for filtering
// @access  Private
router.get('/classes', auth, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user.id);
    const classes = await Prediction.distinct('main_class', { userId });
    res.json(classes);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
