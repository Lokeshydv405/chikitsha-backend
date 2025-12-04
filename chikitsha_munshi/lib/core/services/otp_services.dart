import 'dart:convert';

import 'package:chikitsha_munshi/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final String apiBase = '${AppConfig.serverUrl}/api/auth';

  void showSnack(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> sendOTP(String phone, BuildContext context) async {
    if (phone.isEmpty) {
      showSnack("Please enter a phone number.", context);
      return;
    }


    final response = await http.post(
      Uri.parse('$apiBase/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone}),
    );

    if (response.statusCode == 200) {
      showSnack("OTP sent to $phone", context);
    } else {
      showSnack("Failed to send OTP: ${response.body}", context);
    }
  }

  Future<bool> verifyOTP(BuildContext context, String phone, String otp) async {
    if (otp.isEmpty) {
      showSnack("Invalid OTP.", context);
      return false;
    }

    final response = await http.post(
      Uri.parse('$apiBase/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone, 'code': otp}),
    );

    // setState(() => loading = false);

    if (response.statusCode == 200) {
      showSnack("Phone number verified successfully!", context);
      return true;
      // TODO: Navigate to the home page or next screen
    } else {
      showSnack("Verification failed: ${response.body}", context);
      return false;
    }
  }