require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const userRoutes = require('./routes/userRoutes');
const seedRequestRoutes = require('./routes/seedRequestRoutes');
const plantRoutes = require('./routes/plantRoutes'); // Import the plant routes
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Serve uploaded images

// MongoDB connection
const mongoURI = process.env.MONGODB_URI;
mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log("Connected to MongoDB"))
  .catch(err => console.error("MongoDB connection error:", err));

// Use routes
app.use('/api/users', userRoutes);
app.use('/api/seed-requests', seedRequestRoutes);
app.use('/api/plants', plantRoutes); // Add plant routes

// Server listening
const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';  // Use this to bind to all available network interfaces

app.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
});
