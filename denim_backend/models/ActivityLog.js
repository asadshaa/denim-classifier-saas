const mongoose = require('mongoose');

const activityLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  userEmail: {
    type: String,
    required: true
  },
  action: {
    type: String,
    required: true
    // e.g. 'SINGLE_SCAN', 'BATCH_SCAN', 'FEEDBACK_SUBMITTED', 'LOW_CONFIDENCE_DETECTED', 'LOGIN', 'SETTINGS_CHANGED'
  },
  detail: {
    type: String,
    default: ''
  },
  metadata: {
    type: Object,
    default: {}
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('ActivityLog', activityLogSchema);
