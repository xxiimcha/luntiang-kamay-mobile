// models/userModel.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, default: 'user' },
}, {
  timestamps: true // This will automatically add `createdAt` and `updatedAt` fields
});

const User = mongoose.model('User', userSchema);

module.exports = User;
