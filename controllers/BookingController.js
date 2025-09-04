const Booking = require("../models/Booking");
const CartItem = require("../models/Cart");
const User = require("../models/user");

// Create a new booking from cart
exports.createBooking = async (req, res) => {
    try {
        const { userId, bookingDate, timeSlot, addressIndex, prescriptionUrl } = req.body;

        // Get cart items
        const cartItems = await CartItem.find({ userId }).populate("packageId");
        if (!cartItems.length) {
            return res.status(400).json({ error: "Cart is empty" });
        }

        // Fetch user and selected address
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ error: "User not found" });
        console.log("Selected address index:", addressIndex);
        const selectedAddress = user.addresses[addressIndex];
        if (!selectedAddress) return res.status(400).json({ error: "Invalid address index" });
        console.log("Selected address:", selectedAddress);

        // Price calculation
        let subtotal = 0;
        cartItems.forEach((item) => {
            const price = Number(item.packageId?.offerPrice) || 0;
            subtotal += price;
        });

        const discount = 0; // later apply coupons, offers
        const total = subtotal - discount;

        // Create booking
        const booking = new Booking({
            userId,
            items: cartItems.map((item) => ({
                packageId: item.packageId._id,
                members: item.members
            })),
            bookingDate,
            timeSlot,
            address: selectedAddress.toObject(),
            prescriptionUrl,
            priceBreakdown: { subtotal, discount, total }
        });

        await booking.save();

        // Clear cart after booking
        await CartItem.deleteMany({ userId });

        res.status(201).json({ message: "Booking created successfully", booking });
    } catch (error) {
        console.error("Error creating booking:", error);
        res.status(500).json({ error: "Internal server error" });
    }
};

// Get all bookings of a user
exports.getBookingsByUser = async (req, res) => {
    // Less info: just populate package, do not enrich members
    try {
        const { userId } = req.params;
        const bookings = await Booking.find({ userId })
            .populate("items.packageId")
            .sort({ createdAt: -1 });
        res.status(200).json(bookings);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Internal server error" });
    }
};

//getBookingById
exports.getBookingById = async (req, res) => {
  try {
    const bookingId = req.params.bookingId;

    // Populate package info + its lab details (only _id, name, logoUrl)
    const booking = await Booking.findById(bookingId)
      .populate({
        path: "items.packageId",
        populate: {
          path: "labId",
          model: "Lab",
          select: "_id name logoUrl"
        }
      });

    if (!booking) {
      return res.status(404).json({ error: "Booking not found" });
    }

    // Fetch user to get members array
    const user = await User.findById(booking.userId, "members");

    // Enrich each item's members with user member details
    const enrichedItems = booking.items.map(item => {
      const enrichedMembers = item.members.map(mem => {
        const memberDetail =
          user &&
          (user.members.id(mem.memberId) ||
            user.members.find(
              m => m._id.toString() === mem.memberId.toString()
            ));
        return {
          ...mem.toObject(),
          details: memberDetail ? memberDetail.toObject() : null
        };
      });

      return {
        ...item.toObject(),
        members: enrichedMembers
      };
    });

    const enrichedBooking = {
      ...booking.toObject(),
      items: enrichedItems
    };

    console.log(enrichedBooking);
    res.status(200).json(enrichedBooking);
  } catch (error) {
    console.error("Error fetching booking:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};


// Update payment status
exports.updatePaymentStatus = async (req, res) => {
    try {
        const { bookingId } = req.params;
        const { paymentStatus } = req.body;

        const booking = await Booking.findByIdAndUpdate(
            bookingId,
            { paymentStatus },
            { new: true }
        );

        res.status(200).json(booking);
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
    }
};


