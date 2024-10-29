// models/seedRequestModel.js
const mongoose = require('mongoose');

const seedRequestSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  seedType: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  imagePath: {
    type: String, // This will store the file path or URL of the uploaded image
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'], // Define possible values for status
    default: 'pending', // Set default value to 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('SeedRequest', seedRequestSchema);
