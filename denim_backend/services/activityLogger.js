const ActivityLog = require('../models/ActivityLog');

/**
 * Log an activity event to the DB.
 * @param {string} userId
 * @param {string} userEmail
 * @param {string} action - e.g. 'SINGLE_SCAN'
 * @param {string} detail - human readable description
 * @param {object} metadata - extra data
 */
const logActivity = async (userId, userEmail, action, detail = '', metadata = {}) => {
  try {
    await ActivityLog.create({ userId, userEmail, action, detail, metadata });
  } catch (err) {
    console.error('Activity log failed:', err.message);
    // Non-blocking — don't throw
  }
};

module.exports = { logActivity };
