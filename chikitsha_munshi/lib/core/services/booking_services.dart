import 'dart:convert';
import 'package:chikitsha_munshi/core/utils/user_prefs.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../../models/booking_model.dart';

class BookingService {
  final String baseUrl = '${AppConfig.serverUrl}/api/bookings';

  /// Create a new booking from cart
  Future<Booking?> createBooking({
    required DateTime bookingDate,
    required String timeSlot,
    required int addressIndex,
    String? prescriptionUrl,
  }) async {
    try {
      final userId = await UserPrefs.getUserId();
      final payload = {
        'userId': userId,
        'bookingDate': bookingDate.toIso8601String(),
        'timeSlot': timeSlot,
        'addressIndex': addressIndex,
        if (prescriptionUrl != null) 'prescriptionUrl': prescriptionUrl,
      };
      print('Creating booking with payload: $payload');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Booking created successfully: ${data['message']}');
        return Booking.fromJson(data['booking']);
      } else {
        final error = json.decode(response.body);
        throw Exception('Failed to create booking: ${error['error']}');
      }
    } catch (e) {
      print('Error creating booking: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get all bookings for a user
  Future<List<Booking>> getUserBookings() async {
    final userId = await UserPrefs.getUserId();
    print('Fetching bookings for user: $userId');
    try {
      final response = await http.get(Uri.parse('$baseUrl/$userId'));
      print('Bookings response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map((booking) => Booking.fromJson(booking)).toList();
        } else {
          throw Exception('Unexpected response: $decoded');
        }
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // get booking from booking id
  Future<Booking?> getBooking(String bookingId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$bookingId/info'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to load booking: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching booking: $e');
      throw Exception('Failed to fetch booking: $e');
    }
  }

  /// Update payment status of a booking
  Future<Booking?> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    try {
      final payload = {'paymentStatus': paymentStatus};

      final response = await http.put(
        Uri.parse('$baseUrl/$bookingId/payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to update payment status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get available time slots for a date
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    // This would typically call your backend API
    // For now, returning mock data
    return [
      '8:00-9:00 AM',
      '9:00-10:00 AM',
      '10:00-11:00 AM',
      '11:00-12:00 PM',
      '12:00-1:00 PM',
      '2:00-3:00 PM',
      '3:00-4:00 PM',
      '4:00-5:00 PM',
      '5:00-6:00 PM',
      '6:00-7:00 PM',
      '7:00-8:00 PM',
      '8:00-9:00 PM',
      '9:00-10:00 PM',
    ];
  }

  /// Validate booking data before submission
  bool validateBookingData({
    required DateTime bookingDate,
    required String timeSlot,
    required String addressId,
  }) {
    // Check if booking date is in the future
    if (bookingDate.isBefore(DateTime.now())) {
      return false;
    }

    // Check if time slot is provided
    if (timeSlot.isEmpty) {
      return false;
    }

    // Check if address is selected
    if (addressId.isEmpty) {
      return false;
    }

    return true;
  }
}
