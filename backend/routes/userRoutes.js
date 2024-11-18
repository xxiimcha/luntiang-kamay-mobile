// routes/users.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Register route
router.post('/register', userController.registerUser);

// Login route
router.post('/login', userController.loginUser);

// Get user by ID route
router.get('/:userId', userController.getUserById);

// Update user profile route (with optional profile image upload)
router.put('/:userId', userController.updateUserProfile);

module.exports = router;
