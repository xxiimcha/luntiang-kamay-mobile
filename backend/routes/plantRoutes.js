const express = require('express');
const router = express.Router();
const plantController = require('../controllers/plantController');

// Route to add a new plant
router.post('/add', plantController.addPlant);

// Route to get all plants for a user
router.get('/user-plants', plantController.getUserPlants);

module.exports = router;