import 'package:chikitsha_munshi/screens/Packages/PackageDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/core/services/lab_services.dart';
import 'package:chikitsha_munshi/screens/home/widgets/Packagecard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabInfoPage extends StatefulWidget {
  final String labId;
  final Map<String, dynamic>? initialLabData; // Optional initial data

  const LabInfoPage({
    super.key, 
    required this.labId,
    this.initialLabData,
  });

  @override
  State<LabInfoPage> createState() => _LabInfoPageState();
}

class _LabInfoPageState extends State<LabInfoPage> with TickerProviderStateMixin {
  final LabService _labService = LabService();
  late TabController _tabController;
  
  Map<String, dynamic>? _labData;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingPackages = false;
  bool _isLoadingReviews = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _initializeData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
  }

  Future<void> _initializeData() async {
    if (widget.initialLabData != null) {
      setState(() {
        _labData = widget.initialLabData;
        _isLoading = false;
      });
    }
    
    await _fetchLabDetails();
    await _fetchPackages();
    await _fetchReviews();
  }

  Future<void> _fetchLabDetails() async {
    try {
      final labData = await _labService.getLabById(widget.labId);
      if (!mounted) return;
      if (labData != null) {
        setState(() {
          _labData = labData;
          _isLoading = false;
        });
      } else {
        _showError('Lab not found');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load lab details: $e');
    }
  }

  Future<void> _fetchPackages() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPackages = true;
    });
    try {
      // Use LabService to get lab-specific packages
      print('LabService: Fetching packages for lab ID: ${widget.labId}');
      final packages = await _labService.getLabPackages(widget.labId);
      print('LabService: Found ${packages.length} packages for lab');
      if (!mounted) return;
      setState(() {
        _packages = packages;
        _isLoadingPackages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPackages = false;
      });
      print('Failed to load lab packages: $e');
    }
  }

  Future<void> _fetchReviews() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReviews = true;
    });
    try {
      final reviews = await _labService.getLabReviews(widget.labId);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReviews = false;
      });
      print('Failed to load reviews: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lab Info'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_labData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lab Info'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Lab not found'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderSection(),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPackagesTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildHeaderSection() {
    final address = _labData!['address'] ?? {};
    final contact = _labData!['contact'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.teal.shade100,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60), // Space for app bar
          
          // Lab Logo and Name
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _labData!['logoUrl'] != null && _labData!['logoUrl'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _labData!['logoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_hospital,
                              size: 40,
                              color: Colors.teal,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.local_hospital,
                        size: 40,
                        color: Colors.teal,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labData!['name'] ?? 'Lab Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_labData!['isCertified'] == true) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NABL Certified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating
          Row(
            children: [
              ...LabService.buildRatingStars(_labData!['rating']?.toDouble() ?? 0.0),
              const SizedBox(width: 8),
              Text(
                '${_labData!['rating']?.toStringAsFixed(1) ?? '0.0'} (${_labData!['ratingCount'] ?? 0} reviews)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Address
          if (address.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    LabService.formatLabAddress(address),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 8),
          
          // Contact Info
          if (contact['phone'] != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  contact['phone'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.teal,
        labelColor: Colors.teal,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Packages'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final timings = _labData!['timings'] ?? {};
    final homeCollection = _labData!['homeCollectionAvailable'] ?? false;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services Card
          _buildInfoCard(
            'Services',
            [
              _buildInfoRow(
                Icons.home,
                'Home Collection',
                homeCollection ? 'Available' : 'Not Available',
                homeCollection ? Colors.green : Colors.grey,
              ),
              if (timings['open'] != null && timings['close'] != null)
                _buildInfoRow(
                  Icons.access_time,
                  'Operating Hours',
                  '${timings['open']} - ${timings['close']}',
                  Colors.blue,
                ),
              _buildInfoRow(
                Icons.verified,
                'Certification',
                _labData!['isCertified'] == true ? 'NABL Certified' : 'Not Certified',
                _labData!['isCertified'] == true ? Colors.green : Colors.grey,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Stats
          _buildQuickStats(),
          
          const SizedBox(height: 16),
          
          // About Section (if available)
          if (_labData!['description'] != null) ...[
            _buildInfoCard(
              'About',
              [
                Text(
                  _labData!['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    if (_isLoadingPackages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_packages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No packages available'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PackageCard(
            // Don't show lab name in lab info page (we're already in the lab context)
            showLabName: false,
            
            // Package information from schema
            packageName: package['name'] ?? 'Unknown Package',
            description: package['description'],
            originalPrice: (package['originalPrice'] ?? 0).toDouble(),
            offerPrice: (package['offerPrice'] ?? 0).toDouble(),
            gender: package['gender'],
            fastingRequired: package['fastingRequired'] ?? false,
            fastingDuration: package['fastingDuration'],
            reportTime: package['reportTime'],
            testsIncluded: package['testsIncluded'] != null 
                ? List<Map<String, dynamic>>.from(package['testsIncluded'])
                : null,
            isPopular: package['isPopular'] ?? false,
            
            // Actions
            onTap: () {
              final packageId = package['_id']?.toString();
              if (packageId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PackageDetailsPage(
                      packageId: packageId,
                    ),
                  ),
                );
              }
            },
            onAddToCart: () {
              _addToCart(package);
            },
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Add Review Button
        if (_currentUserId != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        // Reviews List
        Expanded(
          child: _reviews.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.reviews_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No reviews yet'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Packages',
            _packages.length.toString(),
            Icons.medical_services,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Reviews',
            (_labData!['ratingCount'] ?? 0).toString(),
            Icons.reviews,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rating',
            '${_labData!['rating']?.toStringAsFixed(1) ?? '0.0'}/5',
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['user'] ?? {};
    final package = review['package'] ?? {};
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(
                  (user['name']?.toString().isNotEmpty == true 
                      ? user['name'][0].toUpperCase() 
                      : 'U'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? 'Anonymous User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...LabService.buildRatingStars(review['rating']?.toDouble() ?? 0.0, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review['createdAt']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (package['name'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                package['name'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review['comment'],
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _callLab,
              icon: const Icon(Icons.phone),
              label: const Text('Call Lab'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _bookAppointment,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> package) {
    // TODO: Implement add to cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${package['name']} added to cart'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _callLab() {
    final contact = _labData!['contact'];
    if (contact != null && contact['phone'] != null) {
      // TODO: Implement phone call functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${contact['phone']}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
        ),
      );
    }
  }

  void _bookAppointment() {
    Navigator.pushNamed(context, '/booking', arguments: {
      'labId': widget.labId,
      'labName': _labData!['name'],
    });
  }

  void _showAddReviewDialog() {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a review')),
      );
      return;
    }

    // TODO: Implement add review dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add review functionality will be implemented')),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}