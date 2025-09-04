const express = require('express');
const router = express.Router();
const packageController = require('../controllers/PackageController');

router.get('/search', packageController.searchPackages);
router.get('/suggestions', packageController.getSuggestions);
router.get('/', packageController.getAllPackages);
router.get('/:id', packageController.getPackageById);
router.post('/', packageController.createPackage);
router.put('/:id', packageController.updatePackage);
router.delete('/:id', packageController.deletePackage);

module.exports = router; 
