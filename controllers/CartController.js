const CartItem = require("../models/Cart");
const User = require("../models/user"); // ✅ for member populate trick

// ----------------------
// Get cart by user
// ----------------------
exports.getCartByUser = async (req, res) => {
  try {
    const cart = await CartItem.find({ userId: req.params.userId })
      .populate("packageId", "name description offerPrice originalPrice");

    if (!cart.length) {
      return res.json([]);
    }

    const user = await User.findById(req.params.userId, "members");

    const enrichedCart = cart.map((item) => {
  const memberDetails = user.members.filter((m) =>
    item.members.some((mem) => mem.memberId.toString() === m._id.toString())
  );

  // merge selection info back in
  const membersWithSelection = memberDetails.map((m) => {
    const cartMem = item.members.find(
      (mem) => mem.memberId.toString() === m._id.toString()
    );
    return {
      ...m.toObject(),
      selected: cartMem?.selected ?? false,
    };
  });

  return {
    ...item.toObject(),
    members: membersWithSelection,
  };
});


    res.json(enrichedCart);
    console.log("Cart with members:", enrichedCart);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ----------------------
// Add cart item
// ----------------------
exports.addCartItem = async (req, res) => {
  try {
    const { userId, packageId, members = [] } = req.body; // default empty array
    console.log("Adding cart item:", { userId, packageId, members });

    let item = await CartItem.findOne({ userId, packageId });

    if (item) {
      // merge members safely - properly handle member objects
      const existingMemberIds = new Set(item.members.map((m) => m.memberId.toString()));
      
      // Process incoming members
      const newMembers = members.filter(member => {
        const memberId = typeof member === 'object' ? member.memberId : member;
        return !existingMemberIds.has(memberId.toString());
      }).map(member => {
        if (typeof member === 'object' && member.memberId) {
          return {
            memberId: member.memberId,
            selected: member.selected !== undefined ? member.selected : true
          };
        } else {
          return {
            memberId: member,
            selected: true
          };
        }
      });

      item.members.push(...newMembers);
    } else {
      console.log("Creating new item");
      // Ensure members are properly formatted
      const formattedMembers = members.map(member => {
        if (typeof member === 'object' && member.memberId) {
          return {
            memberId: member.memberId,
            selected: member.selected !== undefined ? member.selected : true
          };
        } else {
          return {
            memberId: member,
            selected: true
          };
        }
      });
      
      item = new CartItem({ userId, packageId, members: formattedMembers });
    }

    await item.save();
    res.json(item);
  } catch (err) {
    console.error("Error in addCartItem:", err);
    res.status(500).json({ error: err.message });
  }
};

// ----------------------
// Update member selection
// ----------------------
exports.updateMemberSelection = async (req, res) => {
  try {
    const { cartId, memberId } = req.params;
    const { action } = req.body; // ✅ expects { action: "add" } or { action: "remove" }

    let update = {};

    if (action === "add") {
      // Check if member already exists
      const existingCart = await CartItem.findById(cartId);
      const memberExists = existingCart.members.some(m => m.memberId.toString() === memberId);
      
      if (!memberExists) {
        update = { $addToSet: { members: { memberId, selected: true } } };
      } else {
        // Update existing member's selection
        update = { $set: { "members.$.selected": true } };
        const cart = await CartItem.findOneAndUpdate(
          { _id: cartId, "members.memberId": memberId },
          update,
          { new: true }
        );
        return res.json(cart);
      }
    } else if (action === "remove") {
      update = { $pull: { members: { memberId } } };
    } else {
      return res.status(400).json({ error: "Invalid action. Use add/remove." });
    }

    const cart = await CartItem.findByIdAndUpdate(cartId, update, { new: true });
    res.json(cart);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ----------------------
// Remove member from package
// ----------------------
exports.removeMemberFromCart = async (req, res) => {
  try {
    const { cartId, memberId } = req.params;
    const cart = await CartItem.findByIdAndUpdate(
      cartId,
      { $pull: { members: { memberId } } },
      { new: true }
    );
    res.json(cart);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ----------------------
// Remove entire test from cart
// ----------------------
exports.removeCartItem = async (req, res) => {
  try {
    await CartItem.findByIdAndDelete(req.params.cartId);
    res.json({ message: "Test removed from cart" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
