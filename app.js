const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
// const testRoutes = require("./routes/test.routes"); // ✅ Importing test routes
const labRoutes = require("./routes/labsRoutes"); // ✅ Importing lab routes
const packageRoutes = require('./routes/packageRoutes');
const cartRoutes = require("./routes/cartRoutes"); // ✅ Importing cart routes
// const paymentRoutes = require("./routes/paymentRoutes"); // ✅ Importing payment routes
const bookingRoutes = require("./routes/bookingRoutes"); // ✅ Importing booking routes
const connectToMongoDB = require("./db"); // ✅ Mongoose-based connector

const app = express();
app.use(cors());
app.use(express.json());

    // Route middlewares
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
// ✅ Importing lab routes
app.use("/api/labs", labRoutes); 
// ✅ Importing test routes
// app.use("/api/tests", testRoutes); 
// ✅ Importing package routes
app.use('/api/packages', packageRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/bookings", bookingRoutes); // ✅ Importing booking routes
// app.use("/api/payments", paymentRoutes); // ✅ Importing payment routes
// Connect to MongoDB and start server
(async () => {
  try {
    await connectToMongoDB(); // ✅ No need to assign to client or use .db()

    const PORT = process.env.PORT || 5000;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log("🔐 Twilio Account SID:", process.env.TWILIO_ACCOUNT_SID);
    });
  } catch (err) {
    console.error("❌ Failed to connect to MongoDB:", err);
    process.exit(1);
  }
})();


module.exports = app;
// const express = require("express");
// const app = express();
// app.get("/", (req, res) => {
//   console.log("✅ Request received at /");
//   res.send("Hello from Express!");
// });

// const PORT = process.env.PORT || 5000;
// app.listen(PORT, '0.0.0.0', () => {
//   console.log(`🚀 Server running on port ${PORT}`);
// });
