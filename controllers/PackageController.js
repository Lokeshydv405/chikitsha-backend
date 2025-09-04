const TestPackage = require('../models/TestPackage');
const Lab = require('../models/Lab');

// GET all packages
exports.getAllPackages = async (req, res) => {
  try {
    const packages = await TestPackage.find()
      .populate('labId', 'name logoUrl rating'); // populate only these fields

    // Optional: Restructure each package so lab info is flattened
    
    const formattedPackages = packages.map(pkg => ({
      ...pkg.toObject(),
      labName: pkg.labId?.name,
      labLogo: pkg.labId?.logoUrl,
      labRating: pkg.labId?.rating,
      // labAddress: pkg.labId?.address,
    }));
    // console.log("Fetched packages:", formattedPackages);
    res.status(200).json(formattedPackages);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


// GET one package by ID
exports.getPackageById = async (req, res) => {
  try {
    const pkg = await TestPackage.findById(req.params.id)
      .populate('labId', 'name logoUrl rating address'); 
      // only fetch these fields from Lab

    if (!pkg) return res.status(404).json({ message: 'Package not found' });

    // optional: restructure response if you don’t want full lab object
    res.status(200).json({
      ...pkg.toObject(),
      labId : pkg.labId?._id, // keep labId for reference
      labName: pkg.labId?.name,
      labLogo: pkg.labId?.logoUrl,
      labRating: pkg.labId?.rating,
      labAddress: pkg.labId?.address,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


// POST create new package
exports.createPackage = async (req, res) => {
  try {
    // console.log("📦 Package data received:", req.body);

    const newPackage = new TestPackage(req.body);
    await newPackage.save();

    // ✅ Option 1: Directly update Lab's `packages` array
    if (req.body.labId) {
      const lab = await Lab.findById(req.body.labId);
      if (lab) {
        lab.packages = lab.packages || []; // if field missing
        lab.packages.push(newPackage._id);
        await lab.save();
        console.log(`🏥 Lab (${lab.name}) updated with new package.`);
      } else {
        console.warn("⚠️ Lab not found with given labId.");
      }
    }

    // ✅ Option 2: (Optional) Make internal API call to update Lab — use only if you're microservicing
    /*
    await axios.post(`http://localhost:5000/api/labs/${req.body.labId}/add-package`, {
      packageId: newPackage._id
    });
    */

    // console.log("✅ New package created:", newPackage);
    res.status(201).json(newPackage);
  } catch (err) {
    console.error("❌ Error creating package:", err.message);
    res.status(400).json({ message: err.message });
  }
};
// PUT update package
exports.updatePackage = async (req, res) => {
  try {
    const updated = await TestPackage.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updated) return res.status(404).json({ message: 'Package not found' });
    res.status(200).json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// DELETE package
exports.deletePackage = async (req, res) => {
  try {
    const deleted = await TestPackage.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: 'Package not found' });
    res.status(200).json({ message: 'Package deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


// 🔹 SEARCH packages (with filters, tags & sorting)
exports.searchPackages = async (req, res) => {
  try {
    const { search, labId, minRating, maxPrice, tags, sortBy } = req.query;

    let filter = {};

    // 🔍 Text search on name OR tags
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: "i" } },
        { tags: { $regex: search, $options: "i" } },
      ];
    }

    // 🎯 Lab filter
    if (labId) {
      filter.labId = labId;
    }

    // 💰 Price filter
    if (maxPrice) {
      filter.offerPrice = { $lte: Number(maxPrice) };
    }

    // 🏷️ Tags filter (match any of the tags in query)
    if (tags) {
      const tagsArray = Array.isArray(tags) ? tags : tags.split(",");
      filter.tags = { $in: tagsArray.map(t => t.trim()) };
    }

    let query = TestPackage.find(filter)
      .populate("labId", "name logoUrl rating address");

    // ⭐ Rating filter
    if (minRating) {
      query = query.where("labId.rating").gte(Number(minRating));
    }

    // 📊 Sorting
    let sortOptions = {};
    switch (sortBy) {
      case "priceLow":
        sortOptions.offerPrice = 1;
        break;
      case "priceHigh":
        sortOptions.offerPrice = -1;
        break;
      case "rating":
        sortOptions["labId.rating"] = -1;
        break;
      case "popular":
        sortOptions.isPopular = -1;
        break;
      case "newest":
        sortOptions.createdAt = -1;
        break;
    }
    if (Object.keys(sortOptions).length > 0) {
      query = query.sort(sortOptions);
    }

    const packages = await query;

    // ✅ Send only essential fields
    const formattedPackages = packages.map(pkg => ({
      id: pkg._id,
      name: pkg.name,
      description: pkg.description,
      originalPrice: pkg.originalPrice,
      offerPrice: pkg.offerPrice,
      tags: pkg.tags,
      isPopular: pkg.isPopular,
      createdAt: pkg.createdAt,
      lab: {
        id: pkg.labId?._id,
        name: pkg.labId?.name,
        logo: pkg.labId?.logoUrl,
        rating: pkg.labId?.rating,
        address: pkg.labId?.address,
      },
    }));

    res.status(200).json(formattedPackages);
  } catch (err) {
    console.error("❌ Error searching packages:", err.message);
    res.status(500).json({ message: err.message });
  }
};

// GET suggestions
exports.getSuggestions = async (req, res) => {
  try {
    const { search } = req.query;
    if (!search) return res.json([]);

    // Search by packageName or tags
    const suggestions = await TestPackage.find({
      $or: [
        { name: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ]
    })
    .limit(10) // only send top 10 results
    .select('name tags '); // keep it light

    res.json(suggestions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
