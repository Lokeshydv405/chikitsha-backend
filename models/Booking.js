const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },

    // We’ll copy items from cart to booking so it's independent
    items: [
      {
        packageId: { type: mongoose.Schema.Types.ObjectId, ref: "TestPackage", required: true },
        members: [
          {
            memberId: { type: mongoose.Schema.Types.ObjectId, required: true },
            selected: { type: Boolean, default: true }
          }
        ]
      }
    ],

    // Selected date & slot
    bookingDate: { type: Date, required: true },
    timeSlot: { type: String, required: true }, // e.g. "9:00-10:00 AM"

    // Address
    address: {
      
      line1: { type: String, required: true },
      line2: { type: String },
      city: { type: String, required: true },
      state: { type: String, required: true },
      postalCode: { type: String, required: true },
      country: { type: String, default: "India" }
    },

    // Prescription upload
    prescriptionUrl: { type: String },

    // Price & payment
    priceBreakdown: {
      subtotal: { type: Number, required: true },
      discount: { type: Number, default: 0 },
      total: { type: Number, required: true }
    },

    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "failed"],
      default: "pending"
    },
    orderStatus: {
      type: String,
      enum: ["booked", "processing", "confirmed","Sample Collected","Report Ready","cancelled"],
      default: "booked"
    }
  },
  { timestamps: true }
);

const Booking = mongoose.model("Booking", bookingSchema);
module.exports = Booking;
