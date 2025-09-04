// controllers/LabController.js

const Lab = require('../models/Lab');

exports.getAllLabs = async (req, res) => {
  try {
    const labs = await Lab.find();
    res.json(labs);
  } catch (err) {
    res.status(500).json({ error: 'Server Error' });
  }
};

exports.getLabById = async (req, res) => {
  try {
    const lab = await Lab.findById(req.params.id);
    if (!lab) return res.status(404).json({ message: 'Lab not found' });
    res.json(lab);
  } catch (err) {
    res.status(500).json({ error: 'Server Error' });
  }
};

exports.createLab = async (req, res) => {
  try {
    const lab = new Lab(req.body);
    await lab.save();
    res.status(201).json(lab);
  } catch (err) {
    res.status(400).json({ error: 'Invalid data' });
  }
};

exports.updateLab = async (req, res) => {
  try {
    const lab = await Lab.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!lab) return res.status(404).json({ message: 'Lab not found' });
    res.json(lab);
  } catch (err) {
    res.status(400).json({ error: 'Update failed' });
  }
};

exports.deleteLab = async (req, res) => {
  try {
    const lab = await Lab.findByIdAndDelete(req.params.id);
    if (!lab) return res.status(404).json({ message: 'Lab not found' });
    res.json({ message: 'Lab deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Server Error' });
  }
};

exports.getLabPackages = async (req, res) => {
  // Assuming packages are stored in the lab model
  console.log("Fetching packages for lab ID:", req.params.id);
  try {
    const lab = await Lab.findById(req.params.id).populate('packages');
    if (!lab) return res.status(404).json({ message: 'Lab not found' });
    res.json(lab.packages);
    console.log("Packages found:", lab.packages);
  } catch (err) {
    res.status(500).json({ error: 'Server Error' });
  }
};
// Search labs by name or location
// This function allows searching labs by name or location (city/state)
exports.searchLabs = async (req, res) => {
  console.log("Search query:", req.query.q);
  if (!req.query.q || req.query.q.trim() === "") {
    return res.status(400).json({ error: 'Missing or empty search query' });
  }

  // Use a case-insensitive regex to search by name or address
  // const searchRegex = new RegExp(req.query.q, 'i'); // 'i' for case-insensitive

  try {
    const query = req.query.q;

    if (!query || query.trim() === "") {
      return res.status(400).json({ error: 'Missing or empty search query' });
    }

    const searchRegex = new RegExp(query, 'i'); // case-insensitive

    const labs = await Lab.find({
      $or: [
        { name: searchRegex },
        { 'address.city': searchRegex },
        { 'address.state': searchRegex }
      ]
    });

    if (!labs || labs.length === 0) {
      return res.status(404).json({ message: 'No labs found matching the query' });
    }

    res.json(labs);
  } catch (err) {
    console.error("SearchLabs Error:", err);
    res.status(500).json({ error: 'Search failed' });
  }
};


exports.getNearbyLabs = async (req, res) => {
  try {
    const { lat, lng, radius = 10 } = req.query;
    const nearbyLabs = await Lab.find({
      location: {
        $geoWithin: {
          $centerSphere: [[parseFloat(lng), parseFloat(lat)], radius / 6378.1] // Radius in radians
        }
      }
    });
    res.json(nearbyLabs);
  } catch (err) {
    res.status(500).json({ error: 'Nearby search failed' });
  }
};

exports.getLabRatings = async (req, res) => {
  // Placeholder, implement if reviews stored elsewhere
  res.json([]);
};

exports.submitLabRating = async (req, res) => {
  // Placeholder, depends on review schema
  res.status(501).json({ message: 'Not implemented' });
};

exports.toggleLabStatus = async (req, res) => {
  try {
    const lab = await Lab.findById(req.params.id);
    if (!lab) return res.status(404).json({ message: 'Lab not found' });
    lab.isActive = !lab.isActive;
    await lab.save();
    res.json({ status: lab.isActive });
  } catch (err) {
    res.status(500).json({ error: 'Status toggle failed' });
  }
};

exports.getLabAnalytics = async (req, res) => {
  // Placeholder, depends on data like visits, bookings, etc.
  res.status(501).json({ message: 'Analytics not implemented' });
};

// controllers/LabController.js
exports.addReview = async (req, res) => {
  try {
    const { userId, packageId, rating, comment } = req.body;
    const labId = req.params.id;

    const lab = await Lab.findById(labId);
    if (!lab) return res.status(404).json({ message: 'Lab not found' });

    // Check if user already reviewed for this package
    const alreadyReviewed = lab.reviews.find(
      (r) => r.user.toString() === userId && r.package.toString() === packageId
    );
    if (alreadyReviewed) {
      return res.status(400).json({ message: 'You already reviewed this package at this lab' });
    }

    // Add review
    lab.reviews.push({ user: userId, package: packageId, rating, comment });

    // Update rating stats
    lab.ratingCount = lab.reviews.length;
    lab.rating =
      lab.reviews.reduce((acc, r) => acc + r.rating, 0) / lab.ratingCount;

    await lab.save();

    res.status(201).json({ message: 'Review added successfully', lab });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getReviews = async (req, res) => {
  try {
    const lab = await Lab.findById(req.params.id)
      .populate('reviews.user', 'name')
      .populate('reviews.package', 'name price');

    if (!lab) return res.status(404).json({ message: 'Lab not found' });

    res.json(lab.reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
