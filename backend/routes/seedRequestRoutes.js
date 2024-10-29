const express = require('express');
const router = express.Router();
const seedRequestController = require('../controllers/seedRequestController');
const multer = require('multer');

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage: storage });

// Route to create a new seed request
router.post('/', upload.single('image'), seedRequestController.createSeedRequest);

// Route to fetch seed requests by user ID
router.get('/', seedRequestController.getSeedRequestsByUser);

module.exports = router;
