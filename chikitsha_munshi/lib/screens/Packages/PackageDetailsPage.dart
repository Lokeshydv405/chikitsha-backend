import 'package:chikitsha_munshi/core/services/packages/packagesRelatedServices.dart';
import 'package:chikitsha_munshi/screens/Labs/LabInfoPage.dart';
import 'package:chikitsha_munshi/screens/Packages/SelectPackageMembersPage.dart';
import 'package:flutter/material.dart';

class PackageDetailsPage extends StatefulWidget {
  final String packageId;
  const PackageDetailsPage({super.key, required this.packageId});
  @override
  State<PackageDetailsPage> createState() => _PackageDetailsPageState();
}

class _PackageDetailsPageState extends State<PackageDetailsPage> {
  // sample package data
  bool isLoading = true;
  Map<String, dynamic> package = {};
  List<Map<String, dynamic>> categories = [];
  int totalTests = 0;

  bool showFullDescription = false;
  int selectedMembers = 1;

  // all the functions
  Future<void> _fetchPackage() async {
    try {
      final data = await PackagesRelatedServices().getPackageById(
        widget.packageId,
      );
      setState(() {
        package = data;
        print('Fetched package: $package');
        categories = List<Map<String, dynamic>>.from(
          data['testsIncluded'] ?? [],
        );
        for (var category in package['testsIncluded']) {
          totalTests += (category['tests'] as List).length;
        }
        print('Total tests: $totalTests');
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPackage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Package Details',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.orange,
                    child: const Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                const SizedBox(height: 10),
               

                _buildIconsRow(),
                const Divider(),
                 _buildLabSection(),
                // const SizedBox(height: 12),
                const SizedBox(height: 12),
                _buildPriceRow(),
                const SizedBox(height: 10),
                // // _buildAiRow(),
                // const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 16),
                // _buildBanner(),
                // // const SizedBox(height: 16),
                Text(
                  'Tests Included: ${totalTests} Tests',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                // const SizedBox(height: 12),
                _buildTestsAccordion(),
                // const SizedBox(height: 18),
                // _buildRecommendedTitle(),
                // const SizedBox(height: 8),
                // // _buildRecommendedList(),
                // // const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              // Add to cart functionality
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SelectPackageMembersPage(packageId: widget.packageId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008B75),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }


Widget _buildLabSection() {
  final labName = package['labName'] ?? 'Unknown Lab';
  final labLogo = package['labLogo'] ??
      'https://upload.wikimedia.org/wikipedia/commons/a/a3/Logo_lab.svg'; // fallback
  final labRating = package['rating']?.toDouble() ?? 0.0;

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // lab logo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              labLogo,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: const Icon(Icons.biotech, color: Colors.teal),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // lab details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      labRating > 0 ? labRating.toStringAsFixed(1) : 'No rating',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // button to go to lab page
          TextButton(
            onPressed: () {
              // TODO: navigate to LabPage
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LabInfoPage(labId: package['labId']),
                ),
              );
            },
            child: const Text(
              "View Lab",
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          package['name'] ?? "",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${totalTests} Tests Included',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }

  Widget _buildIconsRow() {
    return Column(
      children: [
        Row(
          children: [
            _smallIconText(
              Icons.restaurant,
              package['fastingDuration'] ?? 'No Fasting Required',
            ),
            const SizedBox(width: 12),
            _smallIconText(Icons.timer, package['reportTime'] ?? 'Unknown'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _smallIconText(Icons.wc, package['gender'] ?? 'Male / Female'),
            const SizedBox(width: 12),
            _smallIconText(
              Icons.cake,
              (package['ageRange'] != null &&
                      package['ageRange']['min'] != null &&
                      package['ageRange']['max'] != null)
                  ? '${package['ageRange']['min']} - ${package['ageRange']['max']} Years'
                  : 'All Ages',
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallIconText(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.teal),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

Widget _buildPriceRow() {
  final double discountedPrice = (package['offerPrice'] ?? 0).toDouble();
  final double originalPrice = (package['originalPrice'] ?? 0).toDouble();

  return Row(
    children: [
      Text(
        '₹${discountedPrice.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 8),
      if (originalPrice > 0 && originalPrice > discountedPrice)
        Text(
          '₹${originalPrice.toStringAsFixed(0)}',
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
    ],
  );
}

  Widget _buildAiRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6F3FF), Color(0xFFEFFBFB)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.purple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.purple),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Need Clarity?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Text('Learn more using AI'),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final desc = package['description'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          showFullDescription
              ? desc
              : (desc.length > 120 ? '${desc.substring(0, 120)}...' : desc),
          style: TextStyle(color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap:
              () => setState(() => showFullDescription = !showFullDescription),
          child: Text(
            showFullDescription ? 'Read Less' : 'Read More',
            style: const TextStyle(color: Colors.teal),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00A99D).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Talk to our health advisors now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'for attractive discounts on your Bookings',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A99D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat With Us'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 92,
              height: 92,
              color: Colors.teal.shade50,
              child: const Icon(Icons.person, size: 48, color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsAccordion() {
    return Column(
      children:
          categories.map((cat) {
            final categoryName = cat['category'] as String? ?? '';
            final tests = (cat['tests'] as List<dynamic>? ?? []).cast<String>();

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: _categoryIcon(categoryName), // optional icon function
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$categoryName (${tests.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                children:
                    tests.map((t) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              t,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  Widget _categoryIcon(String title) {
    const double size = 36;
    IconData icon = Icons.biotech;
    if (title.toLowerCase().contains('liver')) icon = Icons.local_hospital;
    if (title.toLowerCase().contains('urine')) icon = Icons.bubble_chart;
    if (title.toLowerCase().contains('blood')) icon = Icons.bloodtype;
    if (title.toLowerCase().contains('kidney')) icon = Icons.opacity;
    if (title.toLowerCase().contains('glucose')) icon = Icons.monitor_heart;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.teal, size: 20),
    );
  }

  Widget _buildRecommendedTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recommended Blood Test Packages',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget _buildRecommendedList() {
  //   return SizedBox(
  //     height: 160,
  //     child: ListView.separated(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: recommended.length,
  //       separatorBuilder: (context, i) => const SizedBox(width: 12),
  //       itemBuilder: (context, index) {
  //         final package = recommended[index];
  //         return LabCard(
  //           labLogo: package['labLogo'],
  //           labName: package['labName'],
  //           rating: package['rating'],
  //           showLabName: false,
  //           packageName: package['packageName'],
  //           originalPrice: package['originalPrice'],
  //           price: package['price'],
  //           tests: List<String>.from(package['tests']),
  //           badge: package['badge'],
  //           onTap: () {
  //             // if (onPackageTap != null) {
  //             //   onPackageTap!(package);
  //             // } else {
  //               // ScaffoldMessenger.of(context).showSnackBar(
  //               //   SnackBar(
  //               //     content: Text('Tapped: ${package['packageName']}'),
  //               //   ),
  //               // );
  //               // Navigate to package details page
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(
  //                   builder: (context) => PackageDetailsPage(),
  //                 ),
  //               );
  //             }
  //           // },
  //         );
  //         // return Container(
  //         //   width: 220,
  //         //   decoration: BoxDecoration(
  //         //     color: Colors.white,
  //         //     borderRadius: BorderRadius.circular(12),
  //         //     boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, spreadRadius: 2)],
  //         //   ),
  //         //   child: Padding(
  //         //     padding: const EdgeInsets.all(12.0),
  //         //     child: Column(
  //         //       crossAxisAlignment: CrossAxisAlignment.start,
  //         //       children: [
  //         //         Text(pkg['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
  //         //         const SizedBox(height: 6),
  //         //         Row(children: [
  //         //           const Icon(Icons.science_outlined, size: 16),
  //         //           const SizedBox(width: 6),
  //         //           Text('${pkg['tests']} Tests', style: const TextStyle(fontSize: 12)),
  //         //           const Spacer(),
  //         //           Container(
  //         //             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  //         //             decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
  //         //             child: const Text('GROUP OFFERS', style: TextStyle(fontSize: 10, color: Colors.orange)),
  //         //           )
  //         //         ]),
  //         //         const Spacer(),
  //         //         Text(pkg['badge'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
  //         //         const SizedBox(height: 6),
  //         //         Row(
  //         //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //           children: [
  //         //             Text('₹${pkg['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //         //             ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008B75)), child: const Text('Book Now'))
  //         //           ],
  //         //         )
  //         //       ],
  //         //     ),
  //         //   ),
  //         // );
  //       },
  //     ),
  //   );
  // }
}








// final Map<String, dynamic> package = {
//     'name': 'Live More Screening Package With Free Sugar Test',
//     'testsIncluded': 67,
//     'fasting': '12 hrs fasting required',
//     'reportTime': 'Report in 33 Hours',
//     'gender': 'For Male,Female',
//     'age': 'Age: 5-99 yrs.',
//     'price': 389,
//     'originalPrice': 950,
//     'discountPercent': 59,
//     'description': "Worried about your health but still delaying regular checkups? We totally get it. In today's fast-paced life, it's easy to miss health signals. This package covers major organs and common ailments so you can take charge.",
//   };

//   // sample tests categories
//   final List<Map<String, dynamic>> categories = [
//     {
//       'title': 'Liver Function Test',
//       'count': 12,
//       'tests': [
//         'Albumin, Serum',
//         'Alkaline Phosphatase, Serum',
//         'Bilirubin Direct, Serum',
//         'Bilirubin Total, Serum',
//         'GGTP (Gamma GT)',
//         'Proteins, Serum',
//         'SGOT/AST',
//         'SGPT/ALT',
//         'Bilirubin- Indirect, Serum',
//         'Globulin',
//         'A/G Ratio',
//         'SGOT/SGPT Ratio',
//       ]
//     },
//     {
//       'title': 'Urine Routine & Microscopy Extended',
//       'count': 21,
//       'tests': [
//         'Appearance',
//         'Specific Gravity',
//         'pH',
//         'Albumin',
//         'Sugar',
//         'Microscopy',
//         'Bacteria',
//         'RBC',
//         'WBC',
//         'Epithelial Cells',
//         'Casts',
//         'Crystals',
//         // truncated for brevity
//       ]
//     },
//     {
//       'title': 'COMPLETE BLOOD COUNT',
//       'count': 24,
//       'tests': [
//         'Hemoglobin',
//         'RBC Count',
//         'WBC Count',
//         'Platelet Count',
//         'MCV',
//         'MCH',
//         'MCHC',
//         // ...
//       ]
//     },
//     {
//       'title': 'Kidney Function Test',
//       'count': 7,
//       'tests': ['Urea', 'Creatinine', 'Uric Acid', 'Sodium', 'Potassium', 'Chloride', 'Calcium']
//     },
//     {
//       'title': 'Blood Glucose Fasting',
//       'count': 1,
//       'tests': ['Blood Glucose Fasting']
//     },
//     {
//       'title': 'Lipids',
//       'count': 2,
//       'tests': ['Cholesterol-Total', 'Triglycerides']
//     },
//   ];

//   // sample recommended packages
// final List<Map<String, dynamic>> recommended = [
//   {
//     'labLogo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Red_Cross.svg/2048px-Red_Cross.svg.png',
//     'labName': 'Red Cross Diagnostics',
//     'rating': 4.6,
//     'packageName': 'Live More Screening Package With Free Sugar Test',
//     'originalPrice': 599.0,
//     'price': 389.0,
//     'tests': [
//       'Blood Sugar',
//       'Liver Function',
//       'Kidney Function',
//       'Thyroid Profile',
//       'CBC',
//       'Vitamin D'
//     ],
//     // 'badge': 'EXCLUSIVE OFFER'
//   },
//   {
//     'labLogo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Logo_lab.svg/1024px-Logo_lab.svg.png',
//     'labName': 'Healthy India Labs',
//     'rating': 4.8,
//     'packageName': 'Healthy India 2025 Full Body Checkup',
//     'originalPrice': 999.0,
//     'price': 649.0,
//     'tests': [
//       'Complete Blood Count',
//       'Lipid Profile',
//       'Thyroid Profile',
//       'Urine Analysis',
//       'Blood Sugar',
//       'Vitamin B12'
//     ],
//     'badge': 'GROUP OFFERS'
//   },
// ];