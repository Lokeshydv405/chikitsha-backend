const express = require("express");
const Razorpay = require("razorpay");
const crypto = require("crypto");

const router = express.Router();

// 🔹 init razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_SECRET,
});

// 🔹 create order
router.post("/create-order", async (req, res) => {
  try {
    const { amount, currency } = req.body; // amount in INR * 100

    const options = {
      amount: amount * 100, // paise
      currency: currency || "INR",
      receipt: "receipt_" + Date.now(),
    };

    const order = await razorpay.orders.create(options);
    res.json(order);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Order creation failed" });
  }
});

// 🔹 verify payment signature
router.post("/verify", (req, res) => {
  try {
    const { order_id, payment_id, signature } = req.body;

    const sign = crypto
      .createHmac("sha256", process.env.RAZORPAY_SECRET)
      .update(order_id + "|" + payment_id)
      .digest("hex");

    if (sign === signature) {
      return res.json({ success: true, message: "Payment verified" });
    } else {
      return res.status(400).json({ success: false, message: "Invalid signature" });
    }
  } catch (err) {
    res.status(500).json({ error: "Verification failed" });
  }
});


module.exports = router;
