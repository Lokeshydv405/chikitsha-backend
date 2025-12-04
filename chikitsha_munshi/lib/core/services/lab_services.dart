import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class LabService {
  final String baseUrl = '${AppConfig.serverUrl}/api/labs';

  /// Get all labs
  Future<List<Map<String, dynamic>>> getAllLabs() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load labs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching labs: $e');
      throw Exception('Failed to load labs: $e');
    }
  }

  /// Get lab by ID with full details
  Future<Map<String, dynamic>?> getLabById(String labId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$labId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load lab: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lab: $e');
      throw Exception('Failed to load lab: $e');
    }
  }

  /// Get packages offered by a lab
  Future<List<Map<String, dynamic>>> getLabPackages(String labId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$labId/packages'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load lab packages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lab packages: $e');
      throw Exception('Failed to load lab packages: $e');
    }
  }

  /// Get reviews for a lab
  Future<List<Map<String, dynamic>>> getLabReviews(String labId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$labId/reviews'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load lab reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lab reviews: $e');
      throw Exception('Failed to load lab reviews: $e');
    }
  }

  /// Search labs by name or location
  Future<List<Map<String, dynamic>>> searchLabs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search').replace(queryParameters: {'q': query}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to search labs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching labs: $e');
      throw Exception('Failed to search labs: $e');
    }
  }

  /// Get nearby labs
  Future<List<Map<String, dynamic>>> getNearbyLabs({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nearby').replace(queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radius.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load nearby labs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby labs: $e');
      throw Exception('Failed to load nearby labs: $e');
    }
  }

  /// Add a review for a lab
  Future<bool> addReview({
    required String labId,
    required String userId,
    required String packageId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$labId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'packageId': packageId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  /// Helper method to format lab address
  static String formatLabAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    
    if (address['line1'] != null && address['line1'].toString().isNotEmpty) {
      parts.add(address['line1'].toString());
    }
    if (address['line2'] != null && address['line2'].toString().isNotEmpty) {
      parts.add(address['line2'].toString());
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      parts.add(address['city'].toString());
    }
    if (address['state'] != null && address['state'].toString().isNotEmpty) {
      parts.add(address['state'].toString());
    }
    if (address['pincode'] != null && address['pincode'].toString().isNotEmpty) {
      parts.add(address['pincode'].toString());
    }

    return parts.join(', ');
  }

  /// Helper method to get rating stars
  static List<Widget> buildRatingStars(double rating, {double size = 16}) {
    return List.generate(5, (index) {
      return Icon(
        index < rating.floor() ? Icons.star : 
        index < rating ? Icons.star_half : Icons.star_border,
        color: Colors.amber,
        size: size,
      );
    });
  }
}
