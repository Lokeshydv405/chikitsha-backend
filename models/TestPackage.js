const mongoose = require('mongoose');

const TestPackageSchema = new mongoose.Schema({
  name: { type: String, required: true },                     // Package title
  description: { type: String, default: '' },
  originalPrice: { type: Number, required: true,default: 0 }, // Original price of the package
  offerPrice: { type: Number, required: true, default: 0 },     // Discounted price
  gender: { type: String, enum: ['Male', 'Female', 'Male / Female'], default: 'Male / Female' },
  fastingRequired: { type: Boolean, default: false },
  fastingDuration: { type: String, default: '' },             // e.g., "12 hrs"
  reportTime: { type: String, default: '' },                  // e.g., "33 hours"

  applicableGenders: [{ type: String }],                      // ['Male', 'Female']
  ageRange: {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 99 }
  },

  testsIncluded: [{
    category: { type: String, required: true },               // e.g., "Liver Function Test"
    tests: [{ type: String }]                                 // e.g., ["Albumin, Serum", "SGPT/ALT"]
  }],
  labId: { type: mongoose.Schema.Types.ObjectId, ref: 'Lab' }, 
  isPopular: { type: Boolean, default: false },
  tags: [String],
  createdAt: { type: Date, default: Date.now }
});
// ✅ Add text index here
TestPackageSchema.index({ name: "text", tags: "text" });

module.exports = mongoose.model('TestPackage', TestPackageSchema);
