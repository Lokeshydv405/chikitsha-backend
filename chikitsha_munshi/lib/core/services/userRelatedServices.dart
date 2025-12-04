import 'dart:convert';
import 'package:chikitsha_munshi/core/utils/user_prefs.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UserService {
  final String apiBase = '${AppConfig.serverUrl}/api/users';
  // Create user with phone number
  Future<void> createUser(String phone) async {
    final url = Uri.parse('$apiBase/create');
    print('Creating user with phone: $phone');
    print('Request URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data);
        print('User created: ${data['message']}');
        // Save user id if present
        if (data != null) {
          print('User data: $data');
          final userId = data['_id'] ?? data['userId'] ?? data['id'];
          print('Extracted userId: $userId');
          if (userId != null) {
            await UserPrefs.saveUserId(userId.toString());
          }
        }
      } else {
        print('Failed to create user: ${response.statusCode}');
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Get user details using user ID
  Future<Map<String, dynamic>?> getUserDetails() async {
    final userId = await UserPrefs.getUserId();
    final url = Uri.parse('$apiBase/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          // Save user id if present
          final fetchedId = data['_id'] ?? data['id'] ?? userId;
          if (fetchedId != null) {
            await UserPrefs.saveUserId(fetchedId.toString());
          }
        }
        return data;
      } else {
        print('Failed to load user: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // a function to update user details
  Future<Map<String, dynamic>?> updateUserProfile({
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    List<dynamic>? addresses,
  }) async {
    final userId = await UserPrefs.getUserId();
    final url = Uri.parse('$apiBase/update/$userId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (age != null) 'age': age,
          if (height != null) 'height': height,
          if (weight != null) 'weight': weight,
          if (addresses != null) 'addresses': addresses,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to update user: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Fetch user addresses
  // Future<List<Map<String, dynamic>>> fetchUserAddresses(String userId) async {
  Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
    try {
      final userDetails = await getUserDetails();
      if (userDetails != null && userDetails['addresses'] != null) {
        final List<dynamic> addresses = userDetails['addresses'];
        return addresses
            .map((addr) => Map<String, dynamic>.from(addr))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user addresses: $e');
      return [];
    }
  }

  // Future<List<Map<String, dynamic>>> fetchMembers(String userId) async {
  Future<List<Map<String, dynamic>>> fetchMembers() async {
    final userId = await UserPrefs.getUserId();
    final url = Uri.parse('$apiBase/$userId/members');
    print('Fetching members for user *************************************: $userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Members fetched: $data');
        return data.map((m) => Map<String, dynamic>.from(m)).toList();
      } else {
        print('Failed to fetch members: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  Future<void> saveMember({
    required String name,
    required int age,
    required String gender,
    String? relation = 'Not Specified',
    String? avatarPath,
    int? height,
    int? weight,
  }) async {
    final userId = await UserPrefs.getUserId();
    final url = Uri.parse('$apiBase/$userId/members/add');
    print(
      'Saving member: $name, Age: $age, Gender: $gender, Relation: $relation, Height: $height, Weight: $weight',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'age': age,
          if (height != null) 'height': height,
          if (weight != null) 'weight': weight,
          if (avatarPath != null) 'avatarPath': avatarPath,
          'gender': gender,
          if (relation != null) 'relation': relation,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to add member to user: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error adding member to user: $e');
      return null;
    }
  }

  // Function to update a member's details
  Future<bool> updateMember({
    required String memberId,
    required Map<String, dynamic> updatedData,
  }) async {
    final userId = await UserPrefs.getUserId();
    final url = Uri.parse('$apiBase/$userId/members/update/$memberId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );
    return response.statusCode == 200;
  }

  // Function to delete a member
  Future<bool> deleteMember({
    required String memberId,
  }) async {
    final userId = await UserPrefs.getUserId();
    final url = Uri.parse('$apiBase/$userId/members/delete/$memberId');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }
}
