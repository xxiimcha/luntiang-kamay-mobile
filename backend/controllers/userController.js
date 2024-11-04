const User = require('../models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

// Configure multer for file upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Set the upload destination
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Set the file name
  },
});

const upload = multer({ storage: storage });

// Helper function to send error responses consistently
const sendErrorResponse = (res, statusCode, message) => {
  res.status(statusCode).json({ error: message });
};

// Helper function to generate JWT token
const generateToken = (user) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is not set in environment variables.");
  }
  return jwt.sign(
    { userId: user._id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
};

// Register a new user
exports.registerUser = async (req, res) => {
  const { username, email, password, role } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return sendErrorResponse(res, 400, 'Email already registered');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      username,
      email,
      password: hashedPassword,
      role: role || 'user',
    });

    await newUser.save();
    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email,
        role: newUser.role,
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    sendErrorResponse(res, 500, 'Server error');
  }
};

// Login user
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return sendErrorResponse(res, 404, 'User not found');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return sendErrorResponse(res, 400, 'Invalid credentials');
    }

    const token = generateToken(user);

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    sendErrorResponse(res, 500, 'Server error');
  }
};

// Get user details by ID
exports.getUserById = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId).select('-password');
    if (!user) {
      return sendErrorResponse(res, 404, 'User not found');
    }
    res.status(200).json(user);
  } catch (error) {
    console.error('Get user by ID error:', error);
    sendErrorResponse(res, 500, 'Server error');
  }
};

// Update user profile with optional profile image upload
exports.updateUserProfile = [
  upload.single('profileImage'), // Middleware to handle image upload
  async (req, res) => {
    const { userId } = req.params;
    const { username, email, phone } = req.body;
    const updateData = { username, email, phone };

    if (req.file) {
      updateData.profileImage = req.file.path; // Store the file path in the profileImage field
    }

    try {
      const updatedUser = await User.findByIdAndUpdate(userId, updateData, { new: true }).select('-password');

      if (!updatedUser) {
        return sendErrorResponse(res, 404, 'User not found');
      }

      res.status(200).json({
        message: 'Profile updated successfully',
        user: updatedUser,
      });
    } catch (error) {
      console.error('Update profile error:', error);
      sendErrorResponse(res, 500, 'Server error');
    }
  }
];
