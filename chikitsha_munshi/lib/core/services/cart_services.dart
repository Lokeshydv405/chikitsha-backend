import 'dart:convert';
import 'package:chikitsha_munshi/core/config/app_config.dart';
import 'package:chikitsha_munshi/core/utils/user_prefs.dart';
import 'package:chikitsha_munshi/models/cart_model.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl = '${AppConfig.serverUrl}/api/cart';

  /// Get cart items for a specific user
  /// Returns enriched cart data with member details and selection status
  Future<List<CartItem>> getCart() async {
    try {
      final userId = await UserPrefs.getUserId();
      final response = await http.get(Uri.parse("$baseUrl/$userId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Cart items for user $userId: $data");
        return data.map((item) => CartItem.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load cart: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cart: $e");
      throw Exception("Failed to load cart: $e");
    }
  }

  /// Add item to cart with members
  /// Handles both new items and updating existing items with new members
  Future<void> addCartItem({
    required String packageId,
    List<Map<String, dynamic>>? members,
  }) async {
    try {
      final userId = await UserPrefs.getUserId();
      final payload = {
        'userId': userId,
        'packageId': packageId,
        'members': members ?? [],
      };
      print("Adding cart item: $payload");
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to add item to cart: ${response.body}");
      }
      print("Cart item added successfully");
    } catch (e) {
      print("Error adding cart item: $e");
      throw Exception("Failed to add item to cart: $e");
    }
  }

  /// Update member selection (add or remove member from package)
  /// Action can be "add" or "remove"
  Future<void> updateMemberSelection({
    required String cartId,
    required String memberId,
    required String action, // "add" or "remove"
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$cartId/member/$memberId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": action}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update member selection: ${response.body}");
      }

      print("Member selection updated successfully");
    } catch (e) {
      print("Error updating member selection: $e");
      throw Exception("Failed to update member selection: $e");
    }
  }

  /// Remove a specific member from a cart item
  Future<void> removeMemberFromCart({
    required String cartId,
    required String memberId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$cartId/member/$memberId"),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to remove member from cart: ${response.body}");
      }

      print("Member removed from cart successfully");
    } catch (e) {
      print("Error removing member from cart: $e");
      throw Exception("Failed to remove member from cart: $e");
    }
  }

  /// Remove entire cart item (test package)
  Future<void> removeCartItem(String cartId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$cartId"));
      
      if (response.statusCode != 200) {
        throw Exception("Failed to remove cart item: ${response.body}");
      }

      print("Cart item removed successfully");
    } catch (e) {
      print("Error removing cart item: $e");
      throw Exception("Failed to remove cart item: $e");
    }
  }

  /// Helper method to add a member to a specific cart item
  Future<void> addMemberToCart({
    required String cartId,
    required String memberId,
  }) async {
    await updateMemberSelection(
      cartId: cartId,
      memberId: memberId,
      action: "add",
    );
  }

  /// Helper method to remove a member from a specific cart item
  Future<void> removeMemberFromCartItem({
    required String cartId,
    required String memberId,
  }) async {
    await updateMemberSelection(
      cartId: cartId,
      memberId: memberId,
      action: "remove",
    );
  }
}
