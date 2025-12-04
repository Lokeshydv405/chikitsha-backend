import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class PackagesRelatedServices {
  final String baseUrl = '${AppConfig.serverUrl}/api/packages';

  // get all packages
  Future<List<dynamic>> getAllPackages() async {
    print('Fetching all packages');
    print('Requesting: $baseUrl/');
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load packages');
    }
  }

  //get a package by id
  Future<Map<String, dynamic>> getPackageById(String packageId) async {
    if (packageId.isEmpty) {
      throw Exception('Package ID cannot be empty');
    }
    // print('Fetching package with ID: $packageId');
    final response = await http.get(Uri.parse('$baseUrl/$packageId'));
    // print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load package');
    }
  }

  // 🔍 search packages with filters & sorting
  Future<List<dynamic>> searchPackages({
    String? search,
    String? labId,
    double? minRating,
    double? maxPrice,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{};

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (labId != null && labId.isNotEmpty) queryParams['labId'] = labId;
    if (minRating != null) queryParams['minRating'] = minRating.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);

    print('Searching packages: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search packages');
    }
  }

  // get suggestions 
Future<List<dynamic>> getSuggestions(String query) async {
  final response = await http.get(
    Uri.parse('$baseUrl/suggestions?search=$query'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch suggestions');
  }
}


  // Future<List<dynamic>> getRelatedPackages(String packageId) async {
  //   final response = await http.get(Uri.parse('$baseUrl/$packageId/related'));

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to load related packages');
  //   }
  // }
  // Future<Map<int, Map<String, dynamic>>> getDynamicPriceOptions(
  //     String packageId) async {
  //   final package = await getPackageById(packageId);

  //   // assuming backend sends something like:
  //   // "pricingOptions": [
  //   //   { "members": 1, "price": 649, "original": 1664 },
  //   //   { "members": 2, "price": 1165, "original": 3328 }
  //   // ]
  //   if (package.containsKey("pricingOptions")) {
  //     final options = package["pricingOptions"] as List<dynamic>;

  //     return {
  //       for (var opt in options)
  //         opt["members"]: {
  //           "price": opt["price"],
  //           "original": opt["original"]
  //         }
  //     };
  //   }

  //   throw Exception("Pricing options not found for package $packageId");
  // }
  Future<Map<int, Map<String, dynamic>>> getDynamicPriceOptions(
    String packageId) async {
  // 🔹 TEMP: Static mock data until backend sends actual pricingOptions
  final staticOptions = [
    { "members": 1, "price": 649, "original": 1664 },
    { "members": 2, "price": 1165, "original": 3328 },
    { "members": 3, "price": 1647, "original": 4992 },
    { "members": 4, "price": 2130, "original": 6656 },
  ];

  return {
    for (var opt in staticOptions)
      opt["members"] as int: {
        "price": opt["price"],
        "original": opt["original"],
      }
  };
}

}
