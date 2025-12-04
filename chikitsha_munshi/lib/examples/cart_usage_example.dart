import 'package:flutter/material.dart';
import '../core/services/cart_services.dart';
import '../models/cart_model.dart';

class CartExampleUsage extends StatefulWidget {
  final String userId;

  const CartExampleUsage({super.key, required this.userId});

  @override
  State<CartExampleUsage> createState() => _CartExampleUsageState();
}

class _CartExampleUsageState extends State<CartExampleUsage> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Load cart items from backend
  Future<void> _loadCart() async {
    setState(() => isLoading = true);
    try {
      // final items = await _cartService.getCart(widget.userId);
      final items = await _cartService.getCart();
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e');
      setState(() => isLoading = false);
    }
  }

  // Add item to cart with selected members
  Future<void> _addToCart(String packageId, List<String> memberIds) async {
    try {
      final members = memberIds.map((id) => {
        'memberId': id,
        'selected': true,
      }).toList();

      await _cartService.addCartItem(
        // userId: widget.userId,
        packageId: packageId,
        members: members,
      );

      // Refresh cart after adding
      _loadCart();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to cart successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
    }
  }

  // Add a member to existing cart item
  Future<void> _addMemberToCart(String cartId, String memberId) async {
    try {
      await _cartService.addMemberToCart(
        cartId: cartId,
        memberId: memberId,
      );
      
      _loadCart(); // Refresh cart
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added to package!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding member: $e')),
      );
    }
  }

  // Remove a member from cart item
  Future<void> _removeMemberFromCart(String cartId, String memberId) async {
    try {
      await _cartService.removeMemberFromCartItem(
        cartId: cartId,
        memberId: memberId,
      );
      
      _loadCart(); // Refresh cart
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed from package!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing member: $e')),
      );
    }
  }

  // Remove entire cart item
  Future<void> _removeCartItem(String cartId) async {
    try {
      await _cartService.removeCartItem(cartId);
      
      _loadCart(); // Refresh cart
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package removed from cart!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing package: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItemCard(item);
                  },
                ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.packageInfo.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.packageInfo.description != null)
                        Text(
                          item.packageInfo.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${item.packageInfo.offerPrice}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${item.packageInfo.originalPrice}',
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCartItem(item.id),
                ),
              ],
            ),
            
            const Divider(),
            
            // Members section
            const Text(
              'Selected Members:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            if (item.members.isEmpty)
              const Text('No members selected')
            else
              ...item.members.map((member) => _buildMemberTile(item, member)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(CartItem item, CartMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${member.relation}${member.age != null ? ' • ${member.age} years' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removeMemberFromCart(item.id, member.id),
          ),
        ],
      ),
    );
  }
}
