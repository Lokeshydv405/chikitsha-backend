const mongoose = require("mongoose");

// const CartItemSchema = new mongoose.Schema({
//   userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
//   packageId: { type: mongoose.Schema.Types.ObjectId, ref: "TestPackage", required: true },
//   members: [
//     {
//       memberId: { type: mongoose.Schema.Types.ObjectId, required: true }, // store User.members._id here
//     }
//   ]
// }, { timestamps: true });

const cartItemSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    packageId: { type: mongoose.Schema.Types.ObjectId, ref: "TestPackage", required: true },
    members: [
      {
        memberId: { type: mongoose.Schema.Types.ObjectId, ref: "User.members._id", required: true },
        selected: { type: Boolean, default: true }
      }
    ]
  },
  { timestamps: true }
);

module.exports = mongoose.model("CartItem", cartItemSchema);
