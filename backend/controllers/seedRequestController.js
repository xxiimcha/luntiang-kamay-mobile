// controllers/seedRequestController.js
const SeedRequest = require('../models/seedRequestModel');

exports.createSeedRequest = async (req, res) => {
  const { userId, seedType, description } = req.body;
  const imagePath = req.file ? req.file.path : null;

  try {
    const newSeedRequest = new SeedRequest({
      userId,
      seedType,
      description,
      imagePath,
    });

    await newSeedRequest.save();
    res.status(201).json({ message: 'Seed request created successfully', seedRequest: newSeedRequest });
  } catch (error) {
    console.error('Error creating seed request:', error);
    res.status(500).json({ error: 'Server error' });
  }
};
