const mongoose = require('mongoose');

const predictionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  main_class: {
    type: String,
    required: true
  },
  subclass: {
    type: String,
    required: true
  },
  confidence_main: {
    type: Number,
    required: true
  },
  confidence_sub: {
    type: Number,
    required: true
  },
  top_predictions: [
    {
      class: String,
      prob: Number
    }
  ],
  probabilities: [Number], // 21 values
  subclass_probabilities: [Number], // 5 values
  feedback: {
    type: String,
    enum: ['correct', 'incorrect', null],
    default: null
  },
  true_class: {
    type: String,
    default: null
  },
  heatmapUrl: {
    type: String,
    default: null
  },
  inference_time_ms: {
    type: Number,
    default: null
  },
  model_version: {
    type: String,
    default: 'v1.0'
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Prediction', predictionSchema);
