const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Prediction = require('../models/Prediction');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const inferenceService = require('../services/inference.service');
const pLimit = require('p-limit');
const { logActivity } = require('../services/activityLogger');
const User = require('../models/User');

// Simple in-memory job queue for batch processing
const jobs = new Map();

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    const uploadDir = 'uploads/';
    if (!fs.existsSync(uploadDir)){
        fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: function(req, file, cb) {
    cb(null, Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// @route   POST api/predict
// @desc    Upload single image and get prediction
// @access  Private
router.post('/', [auth, upload.single('image')], async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ msg: 'No image uploaded' });

    const imagePath = `/uploads/${req.file.filename}`;
    const result = await inferenceService.runInference(req.file.path);

    const newPrediction = new Prediction({
      userId: req.user.id,
      imageUrl: imagePath,
      ...result,
      feedback: null
    });

    const savedPrediction = await newPrediction.save();

    // Log activity
    const user = await User.findById(req.user.id).select('email');
    const isLowConf = result.confidence_main < 0.80;
    await logActivity(
      req.user.id, user?.email || 'unknown',
      'SINGLE_SCAN',
      `Scanned image → ${result.main_class} (${(result.confidence_main * 100).toFixed(1)}%)`,
      { main_class: result.main_class, confidence: result.confidence_main, predictionId: savedPrediction._id }
    );
    if (isLowConf) {
      await logActivity(
        req.user.id, user?.email || 'unknown',
        'LOW_CONFIDENCE_DETECTED',
        `Low confidence (${(result.confidence_main * 100).toFixed(1)}%) on class ${result.main_class}`,
        { confidence: result.confidence_main, predictionId: savedPrediction._id }
      );
    }

    res.json(savedPrediction);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   POST api/predict/batch
// @desc    Upload multiple images for batch processing
// @access  Private
router.post('/batch', [auth, upload.array('images', 50)], async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ msg: 'No images uploaded' });
    }

    const jobId = Date.now().toString();
    const files = req.files;
    
    // Initialize job in queue
    jobs.set(jobId, {
      status: 'processing',
      total: files.length,
      processed: 0,
      successes: [],
      failures: [],
      startTime: Date.now()
    });

    // Send immediate response with Job ID
    res.json({ jobId, total: files.length, msg: 'Batch processing started' });

    // Process using Optimized Batch Capability
    const userId = req.user.id;
    const filePaths = files.map(f => f.path);
    const imagePaths = files.map(f => `/uploads/${f.filename}`);

    inferenceService.runBatchInference(filePaths)
      .then(async (batchResult) => {
        const job = jobs.get(jobId);
        
        for (let i = 0; i < batchResult.results.length; i++) {
          const result = batchResult.results[i];
          const file = files[i];
          
          if (result.error) {
            job.failures.push({ file: file.originalname, error: result.error });
          } else {
            const predictionData = {
              userId,
              imageUrl: imagePaths[i],
              ...result,
              feedback: null
            };
            const saved = await Prediction.create(predictionData);
            job.successes.push(saved);
          }
          job.processed += 1;
        }

        job.status = 'completed';
        job.endTime = Date.now();
        jobs.set(jobId, job);

        // Log batch completion
        const user = await User.findById(userId).select('email');
        await logActivity(
          userId, user?.email || 'unknown',
          'BATCH_SCAN',
          `Batch job completed: ${job.successes.length} succeeded, ${job.failures.length} failed`,
          { jobId, successes: job.successes.length, failures: job.failures.length }
        );
      })
      .catch((error) => {
        console.error('Batch inference failed:', error);
        const job = jobs.get(jobId);
        job.status = 'failed';
        job.error = error.message;
        jobs.set(jobId, job);
      });

    // Cleanup job after 1 hour
    setTimeout(() => jobs.delete(jobId), 3600000);

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/predict/batch/:jobId
// @desc    Poll batch processing status
// @access  Private
router.get('/batch/:jobId', auth, (req, res) => {
  const job = jobs.get(req.params.jobId);
  if (!job) {
    return res.status(404).json({ msg: 'Job not found or expired' });
  }
  res.json(job);
});

// @route   GET api/predict/history
// @desc    Get user's prediction history
// @access  Private
router.get('/history', auth, async (req, res) => {
  try {
    const predictions = await Prediction.find({ userId: req.user.id }).sort({ timestamp: -1 });
    res.json(predictions);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/predict/:id
// @desc    Get single prediction by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const prediction = await Prediction.findOne({ _id: req.params.id, userId: req.user.id });
    if (!prediction) return res.status(404).json({ msg: 'Prediction not found' });
    res.json(prediction);
  } catch (err) {
    console.error(err.message);
    if(err.kind === 'ObjectId') return res.status(404).json({ msg: 'Prediction not found' });
    res.status(500).send('Server Error');
  }
});

// @route   POST api/predict/feedback/:id
// @desc    Submit feedback for active learning
// @access  Private
router.post('/feedback/:id', auth, async (req, res) => {
  try {
    const { feedback, true_class } = req.body;
    if (!['correct', 'incorrect'].includes(feedback)) {
      return res.status(400).json({ msg: 'Invalid feedback value' });
    }

    const update = { feedback };
    if (feedback === 'incorrect' && true_class) {
      update.true_class = true_class;
    } else if (feedback === 'correct') {
      // If correct, true_class is the main_class itself
      const current = await Prediction.findById(req.params.id);
      update.true_class = current?.main_class;
    }

    const prediction = await Prediction.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { $set: update },
      { new: true }
    );
    if (!prediction) return res.status(404).json({ msg: 'Prediction not found' });
    
    // Log feedback activity
    const user = await User.findById(req.user.id).select('email');
    await logActivity(
      req.user.id, user?.email || 'unknown',
      'FEEDBACK_SUBMITTED',
      `Marked prediction as ${feedback}: ${prediction.main_class}`,
      { feedback, predictionId: req.params.id, main_class: prediction.main_class }
    );
    res.json(prediction);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/predict/heatmap/:id
// @desc    Generate or fetch Grad-CAM heatmap
// @access  Private
router.get('/heatmap/:id', auth, async (req, res) => {
  try {
    const prediction = await Prediction.findOne({ _id: req.params.id, userId: req.user.id });
    if (!prediction) return res.status(404).json({ msg: 'Prediction not found' });

    // Caching: If heatmap already exists, serve it
    if (prediction.heatmapUrl) {
      return res.json({ heatmapUrl: prediction.heatmapUrl });
    }

    // Otherwise, generate it via Python Bridge
    const inputImagePath = path.join(__dirname, '..', prediction.imageUrl);
    const heatmapFilename = `heatmap-${Date.now()}-${req.params.id}.jpg`;
    
    // Ensure heatmaps directory exists
    const heatmapsDir = path.join(__dirname, '..', 'uploads', 'heatmaps');
    if (!fs.existsSync(heatmapsDir)) {
      fs.mkdirSync(heatmapsDir, { recursive: true });
    }
    
    const outputImagePath = path.join(heatmapsDir, heatmapFilename);

    const { spawn } = require('child_process');
    const pythonProcess = spawn('python', [
      path.join(__dirname, '..', 'generate_heatmap.py'), 
      inputImagePath, 
      outputImagePath
    ]);

    pythonProcess.stdout.on('data', async (data) => {
      const output = data.toString().trim();
      if (output === 'SUCCESS') {
        const heatmapUrl = `/uploads/heatmaps/${heatmapFilename}`;
        // Update database with cached URL
        prediction.heatmapUrl = heatmapUrl;
        await prediction.save();
        res.json({ heatmapUrl });
      } else if (output === 'ERROR_CV2_MISSING') {
        if (!res.headersSent) res.status(500).json({ msg: 'Python OpenCV missing. Run: pip install opencv-python numpy' });
      }
    });

    pythonProcess.stderr.on('data', (data) => {
      console.error(`Python Error: ${data}`);
    });

    pythonProcess.on('close', (code) => {
      if (code !== 0 && !res.headersSent) {
        res.status(500).json({ msg: 'Failed to generate heatmap' });
      }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
