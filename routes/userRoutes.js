const express = require('express');
const router = express.Router();
const User = require('../models/user'); // Adjust the path as necessary

// ✅ Create or get user by phone (OTP success)
router.post('/create', async (req, res) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ message: 'Phone number is required' });

  try {
    let user = await User.findOne({ phone });
    if (!user) {
      user = new User({ phone });
      await user.save();
    }
    console.log("User created or fetched:", user);
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }

});


// ✅ Update user details
router.put('/update/:id', async (req, res) => {
  const { email, name, age, height, weight, addresses } = req.body;
  
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    // Only update fields that are allowed
    if (email) user.email = email;
    if (name) user.name = name;
    if (age !== undefined) user.age = age;
    if (height !== undefined) user.height = height;
    if (weight !== undefined) user.weight = weight;
    if (addresses) user.addresses = addresses;
    
    user.updatedAt = Date.now();
    await user.save();
    
    res.status(200).json(user);
  } catch (err) {
    console.error('Error updating user:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});


// ✅ Get all users`
router.get('/:id/members' , async (req, res) => {
  console.log("Fetching members for user with ID:", req.params.id);
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) return res.status(404).json({ message: 'User not found' });
    if (user.members.length === 0) {
      return res.status(404).json({ message: 'No members found for this user' });
    }
    res.status(200).json(user.members);
  } catch (err) {
    console.error("Error fetching members:", err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ Add a new member
router.post('/:id/members/add', async (req, res) => {
  console.log("Adding member to user with ID:", req.params.id);

  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const {
      name,
      age,
      gender,
      height,
      weight,
      healthRecords // optional: can be undefined or empty
    } = req.body;

    const newMember = {
      name,
      age,
      gender,
      height,
      weight,
      healthRecords: Array.isArray(healthRecords) ? healthRecords : []
    };

    console.log("Adding member:", newMember);

    user.members.push(newMember);
    user.updatedAt = Date.now();
    await user.save();

    res.status(201).json({ message: 'Member added', members: user.members });
  } catch (err) {
    console.error("Error adding member:", err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ Update member
router.put('/:id/members/update/:memberId', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const member = user.members.id(req.params.memberId);
    if (!member) return res.status(404).json({ message: 'Member not found' });
    
    Object.assign(member, req.body);
    user.updatedAt = Date.now();
    await user.save();
    
    res.status(200).json({ message: 'Member updated', members: user.members });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Delete member
router.delete('/:id/members/delete/:memberId', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const originalLength = user.members.length;
    
    // Filter out the member by _id
    user.members = user.members.filter(
      member => member._id.toString() !== req.params.memberId
    );
    
    if (user.members.length === originalLength) {
      return res.status(404).json({ message: 'Member not found' });
    }
    
    user.updatedAt = Date.now();
    await user.save();
    
    res.status(200).json({ message: 'Member deleted', members: user.members });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// ✅ Add health record to a member
router.post('/:id/members/:memberId/records/add', async (req, res) => {
  const { testName, date, reportUrl } = req.body;
  
  try {
    const user = await User.findById(req.params.id);
    const member = user?.members.id(req.params.memberId);
    
    if (!member) return res.status(404).json({ message: 'Member not found' });
    
    member.healthRecords.push({ testName, date, reportUrl });
    user.updatedAt = Date.now();
    await user.save();
    
    res.status(201).json({ message: 'Health record added', healthRecords: member.healthRecords });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Update health record
router.put('/:id/members/:memberId/records/update/:recordId', async (req, res) => {
  const { testName, date, reportUrl } = req.body;
  
  try {
    const user = await User.findById(req.params.id);
    const member = user?.members.id(req.params.memberId);
    const record = member?.healthRecords.id(req.params.recordId);
    
    if (!record) return res.status(404).json({ message: 'Health record not found' });
    
    if (testName) record.testName = testName;
    if (date) record.date = date;
    if (reportUrl) record.reportUrl = reportUrl;
    
    user.updatedAt = Date.now();
    await user.save();
    
    res.status(200).json({ message: 'Health record updated', healthRecords: member.healthRecords });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Delete health record
router.delete('/:id/members/:memberId/records/delete/:recordId', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const member = user.members.find(
      m => m._id.toString() === req.params.memberId
    );
    if (!member) return res.status(404).json({ message: 'Member not found' });
    
    const originalLength = member.healthRecords.length;
    
    // Filter out the health record
    member.healthRecords = member.healthRecords.filter(
      record => record._id.toString() !== req.params.recordId
    );
    
    if (member.healthRecords.length === originalLength) {
      return res.status(404).json({ message: 'Health record not found' });
    }
    
    user.updatedAt = Date.now();
    await user.save();
    
    res.status(200).json({
      message: 'Health record deleted',
      healthRecords: member.healthRecords
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Get user by ID
router.get('/:id', async (req, res) => {
  console.log("Fetching user with ID:", req.params.id);
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
