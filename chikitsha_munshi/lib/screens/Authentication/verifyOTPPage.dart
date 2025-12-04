import 'package:chikitsha_munshi/core/services/otp_services.dart';
import 'package:chikitsha_munshi/core/services/userRelatedServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  OTPVerificationPage({required this.phoneNumber});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<String> _otpDigits = ['', '', '', '', '', ''];
  final userService = UserService();
  Timer? _timer;
  int _timeLeft = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
      _canResend = false;
    });
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.length <= 1 && index < _otpDigits.length) {
      setState(() {
        _otpDigits[index] = value;
      });
      
      if (value.isNotEmpty && index < _otpDigits.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        index < _otpDigits.length &&
        _otpDigits[index].isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _resendOTP() {
    if (_canResend) {
      _startTimer();
      setState(() {
        _otpDigits = ['', '', '', '', '', ''];
        for (var controller in _controllers) {
          controller.clear();
        }
      });
      // Call the function to send OTP
      sendOTP(widget.phoneNumber, context);
      _focusNodes[0].requestFocus();
    }
  }

  bool get _isOtpComplete => _otpDigits.every((digit) => digit.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            
            // Phone Icon
            // Container(
            //   width: 120,
            //   height: 180,
            //   decoration: BoxDecoration(
            //     color: Colors.orange.shade50,
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(color: Colors.orange.shade200, width: 2),
            //   ),
            //   child: Center(
            //     child: Container(
            //       width: 60,
            //       height: 60,
            //       decoration: BoxDecoration(
            //         color: Colors.orange.shade100,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Icon(
            //         Icons.smartphone,
            //         color: Colors.orange.shade600,
            //         size: 32,
            //       ),
            //     ),
            //   ),
            // ),

            // Verification video
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child:   Lottie.asset(
                  'assets/gifs/verification.json',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
            ),
            
            
            SizedBox(height: 40),
            
            // Title
            Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Subtitle
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                children: [
                  TextSpan(text: 'Enter the OTP sent to '),
                  TextSpan(
                    text: widget.phoneNumber,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(

                  width: 45,
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) => _onKeyPressed(index, event),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  ),
                );
              }),
            ),
            
            SizedBox(height: 32),
            
            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't receive the OTP? ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                GestureDetector(
                  onTap: _resendOTP,
                  child: Text(
                    _canResend ? 'RESEND OTP' : 'RESEND OTP',
                    style: TextStyle(
                      color: _canResend ? Colors.orange.shade600 : Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            if (!_canResend)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '($_timeLeft seconds)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            
            SizedBox(height: 60),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isOtpComplete ? () async {
                  String otp = _otpDigits.join();
                  // print('OTP entered: $otp');

                  // bool isVerified = verifyOTP(context, widget.phoneNumber, otp) as bool;
                  bool isVerified = true; 
                  if (isVerified) {
                    // Navigate to the next screen or perform further actions
                    await userService.createUser(widget.phoneNumber);
                    Navigator.pushNamed(context, '/main'); // Replace with actual home route
                  }
                  // Handle verification logic here
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOtpComplete ? Colors.blue.shade600 : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: _isOtpComplete ? 2 : 0,
                ),
                child: Text(
                  'VERIFY & PROCEED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}