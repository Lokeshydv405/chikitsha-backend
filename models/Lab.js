const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  package: { type: mongoose.Schema.Types.ObjectId, ref: 'TestPackage', required: true },
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
});

const LabSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  logoUrl: {
    type: String,
    default: ''
  },
  contact: {
    phone: { type: String },
    email: { type: String }
  },
  address: {
    line1: { type: String },
    line2: { type: String },
    city: { type: String },
    state: { type: String },
    pincode: { type: String }
  },
  location: {
    type: { type: String, default: 'Point' },
    coordinates: [Number]
  },
  rating: { type: Number, default: 0 },
  ratingCount: { type: Number, default: 0 },
  packages: [{ type: mongoose.Schema.Types.ObjectId, ref: 'TestPackage' }],
  reviews: [reviewSchema],
  isCertified: {
    type: Boolean,
    default: false
  },
  timings: {
    open: { type: String },
    close: { type: String }
  },
  homeCollectionAvailable: {
    type: Boolean,
    default: false
  }
}, { timestamps: true });

LabSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Lab', LabSchema);
