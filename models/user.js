const mongoose = require('mongoose');

// Schema for Address
const addressSchema = new mongoose.Schema({
  contactname: { type: String, required: true },
  contactphone: { type: String, required: true },
  line1: { type: String, required: true },
  line2: { type: String },
  city: { type: String, required: true },
  state: { type: String, required: true },
  postalCode: { type: String, required: true },
  country: { type: String, default: 'India' },
}, { _id: false });


const memberSchema = new mongoose.Schema({
  name: { type: String, required: true },
  age: { type: Number },
  relation: { type: String },
  dob: { type: Date },
  gender: { type: String },
  height: { type: Number },
  weight: { type: Number },
  healthRecords: [
    {
      testName: { type: String },
      date: { type: Date },
      reportUrl: { type: String }
    }
  ]
}, { _id: true, timestamps: true });

// Schema for the user
const userSchema = new mongoose.Schema({
  phone: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: false
  },
  name: {
    type: String,
    required: false
  },
  walletBalance: {
    type: Number,
    default: 0
  }, 
  height: { type: Number }, // optional for main user
  weight: { type: Number }, // optional for main user
  addresses: {
    type: [addressSchema],
    default: []
  },
  members: {
    type: [memberSchema],
    default: []
  }
}, { timestamps: true });

const User = mongoose.model('User', userSchema);
module.exports = User;