const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000/predict';

exports.runInference = async (imagePath) => {
  try {
    const form = new FormData();
    form.append('file', fs.createReadStream(imagePath));

    const response = await axios.post(AI_SERVICE_URL, form, {
      headers: {
        ...form.getHeaders(),
      },
    });

    return response.data;
  } catch (error) {
    console.error('AI Service Error:', error.response?.data || error.message);
    throw new Error('Inference failed. Make sure the FastAPI service is running on port 8000.');
  }
};

exports.runBatchInference = async (imagePaths) => {
  // For batch, we can either update FastAPI to handle multiple files
  // or simply run them in parallel here.
  const promises = imagePaths.map(path => this.runInference(path));
  const results = await Promise.all(promises);
  return { results };
};
