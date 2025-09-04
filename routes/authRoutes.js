const express = require("express");
const router = express.Router();
const twilio = require("twilio");
const User = require('../models/user'); // Adjust the path as necessary
const { route } = require("./userRoutes");

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const verifySid = process.env.TWILIO_VERIFY_SERVICE_SID;

const client = twilio(accountSid, authToken);

// Send OTP
router.post("/send-otp", async (req, res) => {
  const { phone } = req.body;
  try {
    const verification = await client.verify.v2
      .services(verifySid)
      .verifications.create({ to: phone, channel: "sms" });

    res.status(200).json({ success: true, sid: verification.sid });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.get("/", (req, res) => {
  console.log("✅ GET /api/auth hit");
  res.send("🟢 Auth route is working");
});



  


// Verify OTP
router.post("/verify-otp", async (req, res) => {
  const { phone, code } = req.body;

  console.log("Verifying OTP for phone:", phone, "with code:", code);
  try {
    const verificationCheck = await client.verify.v2
      .services(verifySid)
      .verificationChecks.create({ to: phone, code: code });

    if (verificationCheck.status === "approved") {
      res.status(200).json({ success: true });
    } else {
      res.status(401).json({ success: false, message: "Invalid code" });
    }
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});


// Create or get user after OTP verification
// router.post('/create-user', async (req, res) => {
//   const { phone } = req.body;

//   if (!phone) return res.status(400).json({ message: 'Phone number required' });

//   try {
//     let user = await User.findOne({ phone });

//     if (!user) {
//       user = new User({ phone });
//       await user.save();
//       return res.status(201).json({ message: 'User created', user });
//     }

//     return res.status(200).json({ message: 'User already exists', user });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

module.exports = router;
