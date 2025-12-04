import 'dart:math' as math;
import 'package:chikitsha_munshi/core/services/otp_services.dart';
import 'package:chikitsha_munshi/core/ulits/size_config.dart';
import 'package:chikitsha_munshi/screens/Authentication/verifyOTPPage.dart';
import 'package:flutter/material.dart';

class Phonelogin extends StatefulWidget {
  const Phonelogin({Key? key}) : super(key: key);

  @override
  State<Phonelogin> createState() => _PhoneloginState();
}

class _PhoneloginState extends State<Phonelogin> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  String? _errorMessage;
  bool loading = false;
  final bool otpSent = false;

  final TextEditingController _phoneController = TextEditingController();
  bool isValidIndianPhoneNumber(String phoneNumber) {
    final pattern = RegExp(r'^\+91[6-9]\d{9}$');
    return pattern.hasMatch(phoneNumber);
  }

  @override
  void initState() {
    super.initState();
    _phoneController.text = ''; // Placeholder for phone number input

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Add a subtle continuous animation
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _animationController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Animated Phone Illustration
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background particles
                              ...List.generate(8, (index) {
                                final angle = (index * 45) * (3.14159 / 180);
                                final radius = 70.0;
                                return Positioned(
                                  left: 100 + radius * cos(angle) - 4,
                                  top: 100 + radius * sin(angle) - 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          [
                                            Colors.blue.shade200,
                                            Colors.green.shade200,
                                            Colors.orange.shade200,
                                            Colors.purple.shade200,
                                          ][index % 4],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }),

                              // Phone container
                              Container(
                                width: 80,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.shade100,
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: Colors.orange.shade400,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 30,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade300,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 20,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade200,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Title
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'We will send you an '),
                      TextSpan(
                        text: 'One Time Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '\non this mobile number'),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Phone Number Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 12, bottom: 20),
                            child: Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              maxLength: 10,
                              controller: _phoneController,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "10 digit phone number",
                                fillColor: Colors.white,
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                const SizedBox(height: 40),

                // GET OTP Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.shade200,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle OTP request
                      // print('Requesting OTP for: ${_phoneController.text}');
                      final _phonenumber = "+91" + _phoneController.text.trim();
                      if (!isValidIndianPhoneNumber(_phonenumber)) {
                        setState(() {
                          _errorMessage =
                              "Please enter a valid Indian phone number.";
                        });

                        return;
                      }

                      // sendOTP(_phonenumber, context);

                      // Navigator.pushNamed(
                      //   context,
                      //   '/otpverification',
                      //   arguments: _phonenumber,
                      // );
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => OTPVerificationPage(phoneNumber: _phonenumber),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'GET OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function for cos calculation
double cos(double angle) {
  return math.cos(angle);
}

double sin(double angle) {
  return math.sin(angle);
}

// You'll need to import this at the top of your file
