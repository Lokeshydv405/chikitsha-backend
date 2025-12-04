import 'package:chikitsha_munshi/core/services/cart_services.dart';
import 'package:chikitsha_munshi/models/cart_model.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final String userId;
  const CartPage({super.key, required this.userId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      // final items = await _cartService.getCart(widget.userId);
      final items = await _cartService.getCart();
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Order amount = sum of full price for each selected member
  int get orderAmount => cartItems.fold(
    0,
    (sum, item) =>
        sum +
        item.members.where((m) => m.selected).fold(0, (s, _) => s + item.price),
  );

  // Discounted amount = sum of discounted price for each selected member
  int get discountedAmount => cartItems.fold(
    0,
    (sum, item) =>
        sum +
        item.members
            .where((m) => m.selected)
            .fold(0, (s, _) => s + item.discountedPrice),
  );

  // Total discount = difference
  int get totalDiscount => orderAmount - discountedAmount;

  // To check if any member is selected
  bool get hasSelectedMembers =>
      cartItems.any((item) => item.members.any((m) => m.selected));

  Future<void> _removeCartItem(String cartId) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Remove Test?"),
            content: const Text(
              "Are you sure you want to remove this test from cart?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Remove"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _cartService.removeCartItem(cartId);
      fetchCart();
    }
  }

  void _navigateToBooking() {
    // Prepare booking data
    final bookingData = {
      'userId': widget.userId,
      'cartItems': cartItems.map((item) => {
        'packageId': item.packageInfo.id,
        'packageName': item.packageInfo.name,
        'price': item.packageInfo.offerPrice,
        'originalPrice': item.packageInfo.originalPrice,
        'selectedMembers': item.members
            .where((member) => member.selected)
            .map((member) => {
              'memberId': member.id,
              'name': member.name,
              'relation': member.relation,
            })
            .toList(),
      }).toList(),
      'totalAmount': discountedAmount,
      'originalAmount': orderAmount,
      'discount': totalDiscount,
    };

    // Navigate to booking page
    Navigator.pushNamed(
      context,
      '/booking', // Replace with your actual booking route
      arguments: bookingData,
    );

    // Alternative: Direct navigation with MaterialPageRoute
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BookingPage(
    //       userId: widget.userId,
    //       bookingData: bookingData,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Soft White
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Deep Navy
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];

                        final int mrp = item.price;
                        final int deal = item.discountedPrice;
                        final int savings = (mrp - deal).clamp(0, mrp);
                        final int offPct =
                            (mrp > 0)
                                ? (((mrp - deal) / mrp) * 100).round()
                                : 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Column(
                            children: [
                              // Header row (no overflow)
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  8,
                                  4,
                                ),
                                leading: const CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(
                                    0x1A00897B,
                                  ), // teal w/ low opacity
                                  child: Icon(
                                    Icons.medical_services,
                                    color: Colors.teal,
                                  ),
                                ),
                                title: Text(
                                  item.packageName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF0D1B2A), // Deep Navy
                                  ),
                                ),
                                // prices go in subtitle (wraps if tight)
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 10,
                                    runSpacing: 6,
                                    children: [
                                      // Discounted price pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.withOpacity(0.10),
                                          border: Border.all(
                                            color: Colors.teal,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          "₹$deal",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ),
                                      // MRP (strikethrough)
                                      Text(
                                        "₹$mrp",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFC1C1C1), // Cool Gray
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      // % OFF badge (only if there’s a discount)
                                      if (offPct > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFC7F464,
                                            ).withOpacity(
                                              0.25,
                                            ), // Lime green tint
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            "$offPct% OFF",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0D1B2A),
                                            ),
                                          ),
                                        ),
                                      if (savings > 0)
                                        Text(
                                          "You save ₹$savings",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // delete icon (uses your confirmation in _removeCartItem)
                                trailing: IconButton(
                                  tooltip: "Remove",
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _removeCartItem(item.id),
                                ),
                              ),

                              const Divider(height: 8, thickness: 1),

                              // Members selector in its own ExpansionTile (no heavy trailing)
                              Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    4,
                                    0,
                                    4,
                                    8,
                                  ),
                                  leading: const Icon(
                                    Icons.group,
                                    color: Colors.teal,
                                  ),
                                  title: const Text(
                                    "Selected members for this test",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D1B2A),
                                    ),
                                  ),
                                  children: [
                                    ...item.members.where((m) => m.selected).map((
                                      member,
                                    ) {
                                      return ListTile(
                                        dense: true,
                                        // leading: const Icon(
                                        //   Icons.check_circle,
                                        //   color: Colors.teal,
                                        // ),
                                        title: Text(
                                          "${member.name} (${member.relation})",
                                        ),
                                      );
                                    }).toList(),

                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 🧾 Receipt-style Cart Summary
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cart Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0D1B2A), // Deep Navy
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Order Amount"),
                            Text(
                              "₹$orderAmount",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                          ],
                        ),

                        const Divider(thickness: 1, height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Discount"),
                            Text(
                              "-₹$totalDiscount",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        // Teal "You Saved" banner
                        if (totalDiscount > 0)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "You saved ₹$totalDiscount",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Divider(thickness: 1, height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                            Text(
                              "₹$discountedAmount",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed:
                              hasSelectedMembers
                                  ? () {
                                    // Navigate to booking page
                                    _navigateToBooking();
                                  }
                                  : null, // null makes button disabled
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                hasSelectedMembers
                                    ? Colors.teal
                                    : Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Center(
                            child: Text(
                              "Book Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.teal),
          SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0D1B2A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Browse packages to add tests",
            style: TextStyle(color: Color(0xFFC1C1C1)),
          ),
        ],
      ),
    );
  }
}
