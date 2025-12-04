import 'dart:async';

import 'package:chikitsha_munshi/core/services/packages/packagesRelatedServices.dart';
import 'package:chikitsha_munshi/screens/Packages/PackageDetailsPage.dart';
import 'package:chikitsha_munshi/screens/home/SearchResultsPage.dart';
import 'package:chikitsha_munshi/screens/home/widgets/PackageSlider.dart';
import 'package:chikitsha_munshi/screens/home/widgets/TestimonialsSection.dart';
import 'package:chikitsha_munshi/core/services/lab_services.dart';
import 'package:chikitsha_munshi/screens/Labs/LabInfoPage.dart';
import 'package:chikitsha_munshi/screens/home/widgets/location_picker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  final LabService _labService = LabService();
  final PackagesRelatedServices _packagesService = PackagesRelatedServices();
  int _currentBannerIndex = 0;
  List<Map<String, dynamic>> _popularLabs = [];
  bool _isLoadingLabs = false;
  Timer? _debounce;
  List<dynamic> _suggestions = [];
  bool _isSearching = false;
  String selectedAddress = "No location selected";
  double? lat;
  double? lng;

  // Sample data - replace with your actual data
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Get 50% OFF on Full Body Checkup',
      'title': '50% OFF on Full Body Checkup',
      'subtitle': 'Complete health package at best prices',
      'image': 'assets/images/banner1.jpg',
      'color': Colors.blue,
    },
    {
      'title': 'Free Home Sample Collection',
      'subtitle': 'Book any test and get free pickup',
      'image': 'assets/images/banner2.jpg',
      'color': Colors.green,
    },
    {
      'title': 'NABL Certified Labs',
      'subtitle': 'Trusted results from certified laboratories',
      'image': 'assets/images/banner3.jpg',
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _testCategories = [
    {
      'name': 'Full Body Checkup',
      'icon': Icons.health_and_safety,
      'color': Colors.blue,
      'tag': 'Full Body Checkup',
    },
    {
      'name': 'Thyroid',
      'icon': Icons.medical_services,
      'color': Colors.purple,
      'tag': 'Thyroid',
    },
    {
      'name': 'Diabetes',
      'icon': Icons.bloodtype,
      'color': Colors.red,
      'tag': 'Diabetes',
    },
    {
      'name': 'Heart Health',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'tag': 'Heart',
    },
    {
      'name': 'Liver Function',
      'icon': Icons.biotech,
      'color': Colors.orange,
      'tag': 'Liver',
    },
    {
      'name': 'Kidney Function',
      'icon': Icons.water_drop,
      'color': Colors.cyan,
      'tag': 'Kidney',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
    _fetchPopularLabs();
  }

  void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 400), () async {
    if (query.isNotEmpty) {
      setState(() => _isSearching = true);
      try {
        final results = await _packagesService.getSuggestions(query);
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      } catch (e) {
        print("Error fetching suggestions: $e");
        setState(() => _isSearching = false);
      }
    } else {
      setState(() => _suggestions = []);
    }
  });
}

  Future<void> _fetchPopularLabs() async {
    setState(() {
      _isLoadingLabs = true;
    });

    try {
      final labs = await _labService.getAllLabs();
      // Sort by rating and take top 5
      labs.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
      setState(() {
        _popularLabs = labs.take(5).toList();
        _isLoadingLabs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLabs = false;
      });
      print('Error loading labs: $e');
    }
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _bannerController.hasClients) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        });
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.local_hospital, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chikitsha Munshi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Your Health, Our Priority',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),

        //     Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //       "Your Address:",
        //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //     ),
        //     SizedBox(height: 8),
        //     Text(
        //       selectedAddress,
        //       style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        //     ),
        //     SizedBox(height: 20),
        //     ElevatedButton.icon(
        //       onPressed: () async {
        //         // Navigate to LocationPickerPage
        //         final result = await Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => LocationPickerPage(),
        //           ),
        //         );

        //         // If user picked a location
        //         if (result != null) {
        //           setState(() {
        //             selectedAddress = result['address'];
        //             lat = result['lat'];
        //             lng = result['lng'];
        //           });
        //         }
        //       },
        //       icon: Icon(Icons.location_on),
        //       label: Text("Pick Your Location"),
        //     ),
        //   ],
        // ),
      
            
            // Offer Banners
            _buildOfferBanners(),
            
            // Test Categories
            _buildTestCategories(),
            
            // Popular Labs
            _buildPopularLabs(),
            
            // How it Works
            _buildHowItWorks(),
            
            // Available Packages (existing widget)
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Available Packages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const PackageSlider(),
            
            // Testimonials
            const TestimonialsSection(),
            
            // Trust Banner
            _buildTrustBanner(),
            
            const SizedBox(height: 100), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }


// Widget _buildSearchBar() {
//   return Column(
//     children: [
//       // 🔹 Search Input Box
//       Container(
//         margin: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: TextField(
//           controller: _searchController,
//           onChanged: _onSearchChanged,
//           onSubmitted: (query) {
//             if (query.trim().isNotEmpty) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => SearchResultsPage(query: query.trim()),
//                 ),
//               ).then((_) {
//                 // clear suggestions when coming back
//                 setState(() => _suggestions = []);
//               });
//             }
//           },
//           decoration: InputDecoration(
//             hintText: 'Search packages or tags...',
//             prefixIcon: const Icon(Icons.search, color: Colors.grey),
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.arrow_forward, color: Colors.grey),
//               onPressed: () {
//                 final query = _searchController.text.trim();
//                 if (query.isNotEmpty) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => SearchResultsPage(query: query),
//                     ),
//                   ).then((_) {
//                     setState(() => _suggestions = []);
//                   });
//                 }
//               },
//             ),
//           ),
//         ),
//       ),

//       // 🔹 Suggestions only for names & tags
//       if (_suggestions.isNotEmpty)
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 5,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: _suggestions.length,
//             itemBuilder: (context, index) {
//               final suggestion = _suggestions[index];
//               final name = suggestion['name'] ?? "Unknown";
//               final tags = suggestion['tags'] ?? [];

//               return ListTile(
//                 title: Text(name),
//                 subtitle: tags.isNotEmpty ? Text(tags.join(", ")) : null,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => PackageDetailsPage(
//                         packageId: suggestion['_id'],
//                       ),
//                     ),
//                   ).then((_) {
//                     // clear suggestions after navigating
//                     setState(() => _suggestions = []);
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//     ],
//   );
// }
Widget _buildSearchBar() {
  return GestureDetector(
    onTap: () {
      // 🔹 Navigate directly to Search Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsPage(query: ""), 
          // or a dedicated SearchPage() if you want a type-as-you-search flow
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            "Search by test name or package...",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildOfferBanners() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      banner['color'].withOpacity(0.8),
                      banner['color'],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner['subtitle'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: banner['color'],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Book Now'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _banners.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == entry.key
                    ? Colors.teal
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTestCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Test Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _testCategories.length,
            itemBuilder: (context, index) {
              final category = _testCategories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultsPage(
                        query: '',
                        selectedTags: [category['tag'] as String],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: category['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category['icon'],
                          color: category['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularLabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Labs Nearby',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/labs');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _isLoadingLabs
              ? const Center(child: CircularProgressIndicator())
              : _popularLabs.isEmpty
                  ? const Center(
                      child: Text(
                        'No labs available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _popularLabs.length,
                      itemBuilder: (context, index) {
                        final lab = _popularLabs[index];
                        return _buildLabCard(lab);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab) {
    final address = lab['address'] ?? {};
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LabInfoPage(
              labId: lab['_id'] ?? '',
              initialLabData: lab,
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Lab Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: lab['logoUrl'] != null && lab['logoUrl'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              lab['logoUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.local_hospital,
                                  color: Colors.teal,
                                  size: 20,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.local_hospital,
                            color: Colors.teal,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lab['name'] ?? 'Lab Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lab['isCertified'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NABL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lab['rating']?.toStringAsFixed(1) ?? '0.0'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${lab['ratingCount'] ?? 0} reviews)',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (address.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address['city'] ?? 'Location',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (lab['homeCollectionAvailable'] == true) ...[
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Home Collection',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${lab['packages']?.length ?? 0} packages',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LabInfoPage(
                            labId: lab['_id'] ?? '',
                            initialLabData: lab,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('View Lab'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
  final steps = [
    {
      'icon': Icons.search,
      'title': 'Search Test',
      'description': 'Find tests and labs near you',
    },
    {
      'icon': Icons.home,
      'title': 'Sample Collected',
      'description': 'Free home pickup or visit lab',
    },
    {
      'icon': Icons.receipt,
      'title': 'Get Reports',
      'description': 'Receive reports digitally',
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),

      // Section Title
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'How It Works',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Steps with arrows in between
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return Row(
              children: [
                // Step Block
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // SizedBox(
                    //   width: 90, // fixed width for wrapping nicely
                    //   child: Text(
                    //     step['description'] as String,
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: Colors.grey.shade600,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                // Add arrow only between steps
                if (index < steps.length - 1) ...[
                  // const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  // const SizedBox(width: 16),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    ],
  );
}


  Widget _buildTrustBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Trusted by 10,000+ Customers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrustItem(Icons.verified, 'NABL\nCertified'),
              _buildTrustItem(Icons.speed, 'Quick\nResults'),
              _buildTrustItem(Icons.security, 'Secure &\nPrivate'),
              _buildTrustItem(Icons.support_agent, '24/7\nSupport'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }
}