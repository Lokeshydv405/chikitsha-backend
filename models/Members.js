const mongoose = require('mongoose');

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

// Export both schema and model
const Member = mongoose.model('Member', memberSchema);
module.exports = { Member, memberSchema };
