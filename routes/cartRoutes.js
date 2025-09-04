const express = require("express");
const router = express.Router();
const cartController = require("../controllers/CartController");

// ✅ Get cart by user
router.get("/:userId", cartController.getCartByUser);

// ✅ Add item to cart
router.post("/", cartController.addCartItem);

// ✅ Update member selection inside a test
router.patch("/:cartId/member/:memberId", cartController.updateMemberSelection);

// ✅ Remove a member from a specific package in cart
router.delete("/:cartId/member/:memberId", cartController.removeMemberFromCart);

// ✅ Remove an entire test/package from cart
router.delete("/:cartId", cartController.removeCartItem);

module.exports = router;
