const express = require("express");
const router = express.Router();
const bookingController = require("../controllers/BookingController");

// Create booking
router.post("/", bookingController.createBooking);

// Get user bookings
router.get("/:userId", bookingController.getBookingsByUser);


// gets details of a particular booking by ID
router.get("/:bookingId/info", bookingController.getBookingById);

// Update payment status
router.put("/:bookingId/payment", bookingController.updatePaymentStatus);

module.exports = router;
