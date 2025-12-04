import 'package:chikitsha_munshi/core/services/cart_services.dart';
import 'package:chikitsha_munshi/core/services/packages/packagesRelatedServices.dart';
import 'package:chikitsha_munshi/core/services/userRelatedServices.dart';
import 'package:chikitsha_munshi/core/utils/user_prefs.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class SelectPackageMembersPage extends StatefulWidget {
  final String packageId; // ✅ pass from previous screen
  final String? userId;

  const SelectPackageMembersPage({super.key, required this.packageId, this.userId});

  @override
  State<SelectPackageMembersPage> createState() =>
      _SelectPackageMembersPageState();
}

class _SelectPackageMembersPageState extends State<SelectPackageMembersPage> {
  // ===== THEME COLORS =====
  static const kElectricBlue = Color(0xFF007BFF);
  static const kLimeGreen = Color(0xFF008B75);
  static const kLightLimeGreen = Color.fromARGB(255, 1, 238, 202);
  static const kDeepNavy = Color(0xFF0D1B2A);
  static const kSoftWhite = Color(0xFFF9F9F9);
  static const kCoolGray = Color(0xFFC1C1C1);
  String? _currentUserId;

  // ===== SERVICES =====
  final UserService _userService = UserService();
  final PackagesRelatedServices _packageService = PackagesRelatedServices();

  // ===== STATE =====
  bool _loadingMembers = true;
  bool _isLoading = true;
  String packageName = "";
  Map<int, Map<String, dynamic>> priceOptions = {};
//   int get _currentPrice => widget.package['offerPrice'] ?? 0;
// int get _originalPrice => widget.package['originalPrice'] ?? 0;

  List<Map<String, dynamic>> familyMembers = [];
  final Set<int> _selectedMemberIndexes = {};

  // ===== HELPERS =====
  int get _selectedCount => _selectedMemberIndexes.length;
  int get _maxMembersSupported =>
      priceOptions.keys.isEmpty ? 1 : priceOptions.keys.reduce(max);

  Map<String, num> get _currentPrice {
    if (_selectedCount == 0) return {'price': 0, 'original': 0};
    final tier =
        priceOptions.containsKey(_selectedCount)
            ? _selectedCount
            : priceOptions.keys.reduce(max);
    return {
      'price': priceOptions[tier]!['price']!,
      'original': priceOptions[tier]!['original']!,
    };
  }
//   void _generatePriceOptions() {
//   final original = widget.package['originalPrice'] ?? 0;
//   final offer = widget.package['offerPrice'] ?? 0;

//   priceOptions = {};

//   for (int members = 1; members <= 5; members++) {
//     // scale prices linearly for now
//     final scaledOriginal = original * members;
//     final scaledOffer = offer * members;

//     priceOptions[members] = {
//       'original': scaledOriginal,
//       'price': scaledOffer,
//     };
//   }
// }
  double get _discountPercent {
    final price = _currentPrice['price']!.toDouble();
    final original = _currentPrice['original']!.toDouble();
    if (original <= 0 || price <= 0) return 0;
    return ((original - price) / original) * 100.0;
  }

  String? get _nextPerPersonHint {
    final next = _selectedCount + 1;
    if (priceOptions.containsKey(next) && next > 0) {
      final totalNext = priceOptions[next]!['price']!.toDouble();
      final perPerson = (totalNext / next).ceil();
      return "+ Add 1 more → Pay ₹$perPerson /person!";
    }
    return null;
  }
//==== Loading User ID ====//
  // Future<void> _loadCurrentUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // final userId = prefs.getString('userId'); // Only fetch from SharedPreferences
  //   final userId = await UserPrefs.getUserId();
  //   print(userId);
  //   if (userId != null && userId.isNotEmpty) {
  //     setState(() {
  //       _currentUserId = userId;
  //     });
  //     print("User Id in BookingListPage is $_currentUserId (from SharedPreferences)");
  //     _loadMembers();
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please login to Continue Booking')),
  //     );
  //   }
  // }
  // ===== FETCHING =====
  Future<void> _loadMembers() async {
    try {
      // final userDetails = await _userService.getUserDetails(); // ✅ centralized
      final members = await _userService.fetchMembers(
        // _currentUserId ?? "",
      );
      setState(() {
        familyMembers = members;
        _loadingMembers = false;
      });
    } catch (e) {
      debugPrint("Error loading members: $e");
      setState(() => _loadingMembers = false);
    }
  }

  // Future<void> _loadPackage() async {
  //   try {
  //     // print(widget.packageId);
  //     final package = await _packageService.getPackageById(widget.packageId);
  //     final options = await _packageService.getDynamicPriceOptions(
  //       widget.packageId,
  //     );
  //     print(package);
  //     setState(() {
  //       packageName = package["name"] ?? "";
  //       priceOptions = options;
  //     });
  //   } catch (e) {
  //     debugPrint("Error loading package: $e");
  //   }
  // }
Future<void> _loadPackage() async {
  try {
    final package = await _packageService.getPackageById(widget.packageId);
    print(package);

    // 🔧 Generate priceOptions locally using backend's original + offer price
    final original = package["originalPrice"] ?? 0;
    final offer = package["offerPrice"] ?? 0;

    final generatedOptions = <int, Map<String, dynamic>>{};
    for (int members = 1; members <= 5; members++) {
      generatedOptions[members] = {
        "original": original * members,
        "price": offer * members,
      };
    }

    setState(() {
      packageName = package["name"] ?? "";
      priceOptions = generatedOptions; // use generated map
    });
  } catch (e) {
    debugPrint("Error loading package: $e");
  }
}

  // ===== MEMBER TOGGLE =====
  void _toggleMember(int index) {
    if (_selectedMemberIndexes.contains(index)) {
      setState(() => _selectedMemberIndexes.remove(index));
      return;
    }
    if (_selectedMemberIndexes.length >= _maxMembersSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Group booking supports up to $_maxMembersSupported members.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _selectedMemberIndexes.add(index));
  }

  @override
  void initState() {
    super.initState();
    // _loadCurrentUserId();
    _loadMembers();
    _loadPackage();
    // _generatePriceOptions();
  }

  @override
  Widget build(BuildContext context) {
    final price = _currentPrice['price']!.toInt();
    final original = _currentPrice['original']!.toInt();
    final hasDiscount = original > 0 && price > 0 && _discountPercent > 0;

    return Scaffold(
      backgroundColor: kSoftWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Select Package Members",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          // ===== Header: Package + Dynamic Price (based on selected members) =====
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Expanded(
                  child: Text(
                    packageName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Price Block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _selectedCount == 0 ? "—" : "₹$price",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (original > 0 && _selectedCount > 0)
                      Text(
                        "₹$original",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      "${_selectedCount == 0 ? "No" : _selectedCount} ${_selectedCount == 1 ? "Member" : "Members"}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== Promo / Upsell Banner (only if there's a next tier) =====
          if (_nextPerPersonHint != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kLimeGreen.withOpacity(0.16),
                border: const Border(
                  top: BorderSide(width: 0.5, color: kCoolGray),
                  bottom: BorderSide(width: 0.5, color: kCoolGray),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _nextPerPersonHint!,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ===== Static Price Tiers (NON-clickable) =====
          SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                final members = priceOptions.keys.elementAt(i);
                final data = priceOptions[members]!;
                final isActive = _selectedCount == members;
                return _PricePill(
                  members: members,
                  price: data['price']!.toInt(),
                  original: data['original']!.toInt(),
                  isActive: isActive,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: priceOptions.length,
            ),
          ),

          // ===== Section Title =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Select Family Members",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kCoolGray),
                  ),
                  child: Text(
                    "Max: $_maxMembersSupported",
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // ===== Members List (Multi-select) =====
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: familyMembers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = familyMembers[index];
                final selected = _selectedMemberIndexes.contains(index);
                return InkWell(
                  onTap: () => _toggleMember(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? kElectricBlue.withOpacity(0.08)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? kElectricBlue : kCoolGray,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.04),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: kDeepNavy,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${m['relation']} • ${m['gender']}, ${m['age']}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: selected,
                          onChanged: (_) => _toggleMember(index),
                          activeColor: kElectricBlue,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ===== Footer: Summary + CTA =====
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: kCoolGray, width: 0.8)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Row with total + discount chip
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _selectedCount == 0 ? "—" : "₹$price",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (original > 0 && _selectedCount > 0)
                                Text(
                                  "₹$original",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kLimeGreen.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Save ${_discountPercent.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_selectedCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "For $_selectedCount ${_selectedCount == 1 ? "member" : "members"}",
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<
                            Color
                          >((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color.fromARGB(
                                255,
                                186,
                                244,
                                235,
                              ); // ✅ Light lime green when disabled
                            }
                            return kLimeGreen; // ✅ Normal lime green when enabled
                          }),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black,
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            const Size.fromHeight(48),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                          elevation: MaterialStateProperty.all<double>(2),
                        ),
                        onPressed:
                            _selectedCount == 0
                                ? null
                                : () async {
                                  final selectedMembers =
                                      _selectedMemberIndexes.map((i) {
                                        return {
                                          "memberId":
                                              familyMembers[i]['_id'], // member id
                                          "selected": true,
                                        };
                                      }).toList();

                                  try {
                                    final response = await CartService().addCartItem(
                                      // userId:
                                      //     "688217fd660df33b9a85f42c", // replace with logged-in user id
                                      packageId:
                                          widget
                                              .packageId, // current package id
                                      members: selectedMembers,
                                    );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Added to cart successfully!",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );

                                      Navigator.pushNamed(
                                        context,
                                        '/cart',
                                      ); // 👇 Navigate to cart
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to add to cart: $e",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color:
                                Colors
                                    .white, // ✅ Always readable on lime background
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Non-clickable price pill; highlights when it matches the current selection count.
class _PricePill extends StatelessWidget {
  final int members;
  final int price;
  final int original;
  final bool isActive;

  const _PricePill({
    required this.members,
    required this.price,
    required this.original,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    const kElectricBlue = Colors.teal;
    const kCoolGray = Color(0xFFC1C1C1);

    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      constraints: const BoxConstraints(minWidth: 85, maxWidth: 150),

      decoration: BoxDecoration(
        color: isActive ? kElectricBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? kElectricBlue : kCoolGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$members ${members == 1 ? "Member" : "Members"}",
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "₹$price",
            style: TextStyle(
              color: isActive ? Colors.white : kElectricBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "₹$original",
            style: TextStyle(
              color: isActive ? Colors.white70 : Colors.grey,
              decoration: TextDecoration.lineThrough,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
