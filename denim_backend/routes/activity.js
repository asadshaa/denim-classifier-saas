const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const ActivityLog = require('../models/ActivityLog');
const mongoose = require('mongoose');

// @route   GET api/activity
// @desc    Get recent activity logs (polling for live feed)
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user.id);
    const limit = parseInt(req.query.limit) || 20;
    
    const logs = await ActivityLog.find({ userId })
      .sort({ timestamp: -1 })
      .limit(limit);
    
    res.json(logs);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/activity/all (admin only in future RBAC)
// @desc    Get all user activity logs
// @access  Private
router.get('/all', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const logs = await ActivityLog.find()
      .sort({ timestamp: -1 })
      .limit(limit)
      .populate('userId', 'email role');
    
    res.json(logs);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
