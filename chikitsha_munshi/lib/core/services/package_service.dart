import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chikitsha_munshi/core/config/app_config.dart';

class PackageService {
  static String get baseUrl => '${AppConfig.serverUrl}/api/packages';

  // Get all packages
  static Future<List<Map<String, dynamic>>> getAllPackages() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      // print('PackageService: Response status: ${response.statusCode}');
      // print('PackageService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print('PackageService: Decoded data type: ${data.runtimeType}');
        // print('PackageService: Decoded data: $data');
        
        // Handle different response structures
        List<dynamic> packagesData;
        if (data is Map<String, dynamic>) {
          packagesData = data['packages'] ?? data['data'] ?? [];
        } else if (data is List) {
          packagesData = data;
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        
        // Ensure each item is a Map<String, dynamic>
        final packages = <Map<String, dynamic>>[];
        for (var item in packagesData) {
          if (item is Map<String, dynamic>) {
            packages.add(item);
          } else {
            print('PackageService: Skipping invalid package item: $item');
          }
        }
        
        // print('PackageService: Returning ${packages.length} packages');
        return packages;
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching packages: $e');
      throw Exception('Failed to load packages: $e');
    }
  }

  // Get package by ID
  static Future<Map<String, dynamic>?> getPackageById(String packageId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$packageId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['package'] ?? data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load package: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching package by ID: $e');
      throw Exception('Failed to load package: $e');
    }
  }

  // Get packages by lab ID
  static Future<List<Map<String, dynamic>>> getPackagesByLabId(String labId) async {
    print('PackageService: Fetching packages for lab ID: $labId');
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.serverUrl}/api/labs/$labId/packages'),
        headers: {'Content-Type': 'application/json'},
      );
      // print('PackageService: Response status: ${response.statusCode}');
      // print('PackageService: Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['packages'] ?? data);
      } else {
        throw Exception('Failed to load lab packages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lab packages: $e');
      throw Exception('Failed to load lab packages: $e');
    }
  }

  // Search packages
  static Future<List<Map<String, dynamic>>> searchPackages(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['packages'] ?? data);
      } else {
        throw Exception('Failed to search packages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching packages: $e');
      throw Exception('Failed to search packages: $e');
    }
  }

  // Get popular packages
  static Future<List<Map<String, dynamic>>> getPopularPackages({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/popular?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['packages'] ?? data);
      } else {
        throw Exception('Failed to load popular packages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popular packages: $e');
      throw Exception('Failed to load popular packages: $e');
    }
  }

  // Filter packages by criteria
  static Future<List<Map<String, dynamic>>> getFilteredPackages({
    String? gender,
    double? minPrice,
    double? maxPrice,
    bool? fastingRequired,
    String? category,
  }) async {
    try {
      Map<String, String> queryParams = {};
      
      if (gender != null) queryParams['gender'] = gender;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (fastingRequired != null) queryParams['fastingRequired'] = fastingRequired.toString();
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$baseUrl/filter').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['packages'] ?? data);
      } else {
        throw Exception('Failed to filter packages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error filtering packages: $e');
      throw Exception('Failed to filter packages: $e');
    }
  }

  // Helper method to format test categories for display
  static String formatTestsIncluded(List<dynamic>? testsIncluded) {
    if (testsIncluded == null || testsIncluded.isEmpty) return '';
    
    List<String> allTests = [];
    for (var category in testsIncluded) {
      if (category is Map<String, dynamic>) {
        final tests = category['tests'] as List<dynamic>? ?? [];
        allTests.addAll(tests.map((test) => test.toString()));
      }
    }
    
    return allTests.join(', ');
  }

  // Helper method to get test count
  static int getTestCount(List<dynamic>? testsIncluded) {
    if (testsIncluded == null || testsIncluded.isEmpty) return 0;
    
    int count = 0;
    for (var category in testsIncluded) {
      if (category is Map<String, dynamic>) {
        final tests = category['tests'] as List<dynamic>? ?? [];
        count += tests.length;
      }
    }
    
    return count;
  }

  // Helper method to format fasting duration
  static String formatFastingInfo(bool fastingRequired, String? fastingDuration) {
    if (!fastingRequired) return '';
    if (fastingDuration != null && fastingDuration.isNotEmpty) {
      return 'Fasting: $fastingDuration';
    }
    return 'Fasting Required';
  }

  // Helper method to format gender display
  static String formatGender(String? gender) {
    if (gender == null || gender == 'Male / Female') return 'All';
    return gender;
  }

  // Helper method to calculate discount percentage
  static int calculateDiscountPercentage(double originalPrice, double offerPrice) {
    if (originalPrice <= 0 || offerPrice >= originalPrice) return 0;
    return (((originalPrice - offerPrice) / originalPrice) * 100).round();
  }
}
