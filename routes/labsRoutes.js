// routes/labs.routes.js

const express = require('express');
const router = express.Router();
const LabController = require('../controllers/LabController');

/*
 * IMPORTANT: Specific routes should come before dynamic `:id` routes
 * to avoid misinterpretation of routes like `/search` or `/nearby` as IDs.
 */

// Search labs by name or location
router.get('/search', LabController.searchLabs);

// Get nearby labs by lat/lng and radius
router.get('/nearby', LabController.getNearbyLabs);

// Get all labs
router.get('/', LabController.getAllLabs);

/*
 * Routes with :id should always come after the above specific routes
 */

// Get packages offered by a lab
router.get('/:id/packages', LabController.getLabPackages);

// Get all reviews for a lab
router.get('/:id/ratings', LabController.getLabRatings);

// Submit a new lab review
router.post('/:id/ratings', LabController.submitLabRating);

// Get lab-level performance data
router.get('/:id/analytics', LabController.getLabAnalytics);
// routes/labs.routes.js
router.post('/:id/reviews', LabController.addReview);   // Add new review
router.get('/:id/reviews', LabController.getReviews);   // Fetch reviews

// Activate/Deactivate lab listing
router.put('/:id/status', LabController.toggleLabStatus);

// Get a single lab by ID
router.get('/:id', LabController.getLabById);

// Update lab details
router.put('/:id', LabController.updateLab);

// Delete a lab
router.delete('/:id', LabController.deleteLab);

// Create a new lab (should be after all GET/PUT routes to avoid conflict)
router.post('/', LabController.createLab);

module.exports = router;
