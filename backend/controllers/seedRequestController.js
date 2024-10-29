const SeedRequest = require('../models/seedRequestModel');

// Create a new seed request
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

// Fetch seed requests by userId
exports.getSeedRequestsByUser = async (req, res) => {
  const { userId } = req.query;

  try {
    const seedRequests = await SeedRequest.find({ userId }).sort({ createdAt: -1 }); // Sort by newest first
    res.status(200).json(seedRequests);
  } catch (error) {
    console.error('Error fetching seed requests:', error);
    res.status(500).json({ error: 'Server error' });
  }
};
