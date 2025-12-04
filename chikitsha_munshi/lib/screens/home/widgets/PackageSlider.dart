import 'package:chikitsha_munshi/core/services/package_service.dart';
import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/screens/Packages/PackageDetailsPage.dart';
import 'package:chikitsha_munshi/screens/home/widgets/Packagecard.dart';

class PackageSlider extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onPackageTap;
  final bool showLabName;

  const PackageSlider({
    super.key,
    this.onPackageTap,
    this.showLabName = true,
  });

  @override
  State<PackageSlider> createState() => _PackageSliderState();
}

class _PackageSliderState extends State<PackageSlider> {
  List<dynamic> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final data = await PackageService.getAllPackages();
      print('PackageSlider: Received data type: ${data.runtimeType}');
      print('PackageSlider: Data content: $data');
      
      setState(() {
        packages = data;
        isLoading = false;
      });
    } catch (e) {
      print('PackageSlider: Error fetching packages: $e');
      
      // Fallback to mock data for testing
      setState(() {
        packages = _getMockPackages();
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using demo data: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }


// Mock data for testing when backend is not available
List<Map<String, dynamic>> _getMockPackages() {
  return [
    {
      '_id': 'mock1',
        'name': 'Complete Blood Count (CBC)',
        'description': 'Comprehensive blood analysis including RBC, WBC, platelets, and hemoglobin levels',
        'originalPrice': 500,
        'offerPrice': 350,
        'gender': 'Male / Female',
        'fastingRequired': false,
        'reportTime': '24 hours',
        'isPopular': true,
        'testsIncluded': [
          {
            'category': 'Blood Count',
            'tests': ['RBC Count', 'WBC Count', 'Platelet Count', 'Hemoglobin']
          }
        ],
        'labId': {
          'name': 'City Lab',
          'logo': 'https://via.placeholder.com/100',
          'rating': 4.5
        }
      },
      {
        '_id': 'mock2',
        'name': 'Liver Function Test',
        'description': 'Evaluate liver health and function',
        'originalPrice': 800,
        'offerPrice': 600,
        'gender': 'Male / Female',
        'fastingRequired': true,
        'fastingDuration': '12 hours',
        'reportTime': '48 hours',
        'isPopular': false,
        'testsIncluded': [
          {
            'category': 'Liver Function',
            'tests': ['SGPT/ALT', 'SGOT/AST', 'Bilirubin', 'Albumin']
          }
        ],
        'labId': {
          'name': 'Metro Diagnostics',
          'logo': 'https://via.placeholder.com/100',
          'rating': 4.2
        }
      }
    ];
  }

  // Helper method to safely convert to double
  double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    } 

    if (packages.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No packages available')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final package = packages[index];
          print('PackageSlider: Processing package $index: ${package.runtimeType}');
          
          // Ensure package is a Map
          if (package is! Map<String, dynamic>) {
            print('PackageSlider: Package at index $index is not a Map: $package');
            return Container(
              width: 300,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Invalid package data'),
              ),
            );
          }
          
          // Safe data extraction with null checks
          final Map<String, dynamic> packageData = package;
          
          // Safe lab data extraction
          // final labData = packageData['labId'];
          String? labLogo = packageData['labLogo'];
          String? labName = packageData['labName'];
          double? rating  = _safeToDouble(packageData['labRating']);

          // if (labData is Map<String, dynamic>) {
          //   labLogo = labData['logo']?.toString();
          //   labName = labData['name']?.toString();
          //   rating = _safeToDouble(labData['rating']);
          // }
          
          // Safe tests included extraction
          List<Map<String, dynamic>>? testsIncluded;
          if (packageData['testsIncluded'] is List) {
            try {
              testsIncluded = (packageData['testsIncluded'] as List)
                  .map((item) => item is Map<String, dynamic> ? item : <String, dynamic>{})
                  .toList();
            } catch (e) {
              print('PackageSlider: Error parsing testsIncluded: $e');
              testsIncluded = null;
            }
          }
          // print(packageData);
          print(labName);
          return PackageCard(
            // Lab information
            labLogo: labLogo ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/240px-No_image_available.svg.png',
            labName: labName ?? 'Unknown Lab',
            rating: rating ?? 0.0,
            showLabName: widget.showLabName,
            
            // Package information
            packageName: packageData['name']?.toString() ?? 'Unknown Package',
            description: packageData['description']?.toString(),
            originalPrice: _safeToDouble(packageData['originalPrice']) ?? 0.0,
            offerPrice: _safeToDouble(packageData['offerPrice']) ?? 0.0,
            gender: packageData['gender']?.toString(),
            fastingRequired: packageData['fastingRequired'] == true,
            fastingDuration: packageData['fastingDuration']?.toString(),
            reportTime: packageData['reportTime']?.toString(),
            testsIncluded: testsIncluded,
            isPopular: packageData['isPopular'] == true,
            
            // Actions
            onTap: () {
              if (widget.onPackageTap != null) {
                widget.onPackageTap!(packageData);
              } else {
                final packageId = packageData['_id']?.toString();
                if (packageId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PackageDetailsPage(
                        packageId: packageId,
                      ),
                    ),
                  );
                }
              }
            },
            onAddToCart: () {
              final packageName = packageData['name']?.toString() ?? 'Package';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$packageName added to cart'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
