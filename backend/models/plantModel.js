const mongoose = require('mongoose');

const plantSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  plantName: {
    type: String,
    required: true,
  },
  progress: {
    type: Number,
    default: 0, // Set initial progress to 0
    min: 0,
    max: 1, // This keeps the value between 0 and 1
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Plant', plantSchema);
