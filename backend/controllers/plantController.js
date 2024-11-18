const Plant = require('../models/plantModel'); // Import the Plant model

// Controller function to add a new plant
exports.addPlant = async (req, res) => {
  const { userId, plantName } = req.body;

  if (!userId || !plantName) {
    return res.status(400).json({ error: 'User ID and Plant Name are required.' });
  }

  try {
    // Create a new plant with default progress of 0
    const newPlant = new Plant({
      userId,
      plantName,
      progress: 0, // Default progress value
    });

    await newPlant.save(); // Save the plant to the database
    res.status(201).json({ message: 'Plant added successfully', plant: newPlant });
  } catch (error) {
    console.error('Error adding plant:', error);
    res.status(500).json({ error: 'Server error' });
  }
};

// Controller function to fetch all plants for a user
exports.getUserPlants = async (req, res) => {
  const { userId } = req.params;
  console.log(`Fetching plants for userId: ${userId}`); // Debugging log
  try {
    const plants = await Plant.find({ userId });
    res.status(200).json(plants);
  } catch (error) {
    console.error('Error fetching plants:', error);
    res.status(500).json({ error: 'Failed to fetch plants' });
  }
};
