// const Test = require('../models/test');
// const Lab = require('../models/Lab');
// // Get all tests
// exports.getAllTests = async (req, res) => {
//   try {
//     const tests = await Test.find();
//     res.json(tests);
//   } catch (err) {
//     res.status(500).json({ error: 'Server Error' });
//   }
// };

// // Get a test by ID
// exports.getTestById = async (req, res) => {
//   try {
//     const test = await Test.findById(req.params.id);
//     if (!test) return res.status(404).json({ message: 'Test not found' });
//     res.json(test);
//   } catch (err) {
//     res.status(500).json({ error: 'Server Error' });
//   }
// };

// // Create a new test
// exports.createTest = async (req, res) => {
//   try {
//     const { labId, ...testData } = req.body;

//     // 1. Create the test package
//     const newTest = new Test({ ...testData, labId });
//     await newTest.save();

//     // 2. Push the package reference into the Lab
//     if (labId) {
//       await Lab.findByIdAndUpdate(
//         labId,
//         { $push: { packages: newTest._id } },
//         { new: true }
//       );
//     }

//     res.status(201).json(newTest);
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// // Update test
// exports.updateTest = async (req, res) => {
//   try {
//     const updated = await Test.findByIdAndUpdate(req.params.id, req.body, { new: true });
//     if (!updated) return res.status(404).json({ message: 'Test not found' });
//     res.json(updated);
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// // Delete test
// exports.deleteTest = async (req, res) => {
//   try {
//     const deleted = await Test.findByIdAndDelete(req.params.id);
//     if (!deleted) return res.status(404).json({ message: 'Test not found' });

//     // remove the reference from Lab.packages
//     if (deleted.labId) {
//       await Lab.findByIdAndUpdate(
//         deleted.labId,
//         { $pull: { packages: deleted._id } }
//       );
//     }

//     res.json({ message: 'Test deleted successfully' });
//   } catch (err) {
//     res.status(500).json({ error: 'Server Error' });
//   }
// };
 