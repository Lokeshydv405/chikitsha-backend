// import 'package:chikitsha_munshi/core/ulits/termsNotice.dart';
// import 'package:flutter/material.dart';
// import 'package:chikitsha_munshi/core/ulits/size_config.dart';

// class PhoneLoginPage extends StatefulWidget {
//   const PhoneLoginPage({super.key});

//   @override
//   State<PhoneLoginPage> createState() => _PhoneLoginPageState();
// }

// class _PhoneLoginPageState extends State<PhoneLoginPage> {
//   final TextEditingController _phoneController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   String countryCode = "+91";

//   void _sendOtp() {
//     if (_formKey.currentState!.validate()) {
//       final phone = "$countryCode${_phoneController.text.trim()}";
//       // 🔐 Trigger OTP logic here
//       print("Sending OTP to $phone");
//       // Navigator.push to VerifyOtpPage if needed
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig.init(context); // Initialize scaling

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: SizeConfig.scaleWidth(24),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: SizeConfig.scaleHeight(60)),

//               // 🩺 App Title
//               Text(
//                 "Chikitsha Munshi",
//                 style: TextStyle(
//                   fontSize: SizeConfig.scaleWidth(30),
//                   fontWeight: FontWeight.bold,
//                   color: Colors.teal,
//                 ),
//               ),

//               SizedBox(height: SizeConfig.scaleHeight(50)),

//               // 📞 Phone Input
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Login",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: SizeConfig.scaleWidth(20),
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: SizeConfig.scaleHeight(10)),
//                     Row(
//                       children: [
//                         // Country Code
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             vertical: SizeConfig.scaleHeight(14),
//                             horizontal: SizeConfig.scaleWidth(12),
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade400),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             countryCode,
//                             style: TextStyle(fontSize: SizeConfig.scaleWidth(16)),
//                           ),
//                         ),
//                         SizedBox(width: SizeConfig.scaleWidth(10)),
//                         // Phone Number Field
//                         Expanded(
//                           child: TextFormField(
//                             controller: _phoneController,
//                             keyboardType: TextInputType.phone,
//                             maxLength: 10,
//                             style: TextStyle(fontSize: SizeConfig.scaleWidth(16)),
//                             decoration: InputDecoration(
//                               hintText: "Enter your phone number",
//                               counterText: '',
//                               contentPadding: EdgeInsets.symmetric(
//                                 vertical: SizeConfig.scaleHeight(18),
//                                 horizontal: SizeConfig.scaleWidth(14),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return "Please enter your number";
//                               }
//                               if (value.trim().length != 10) {
//                                 return "Enter valid 10-digit number";
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: SizeConfig.scaleHeight(30)),

//               // 🔘 Send OTP Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _sendOtp,
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(
//                       vertical: SizeConfig.scaleHeight(16),
//                     ),
//                     backgroundColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     "Send OTP",
//                     style: TextStyle(
//                       fontSize: SizeConfig.scaleWidth(16),
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//               const Spacer(),

//               // 🔒 Terms & Info
//               // Text(
//               //   "By continuing, you agree to our Terms of Service and Privacy Policy.",
//               //   textAlign: TextAlign.center,
//               //   style: TextStyle(
//               //     fontSize: SizeConfig.scaleWidth(13),
//               //     color: Colors.grey.shade600,
//               //   ),
//               // ),
//               const TermsNotice(),
//               SizedBox(height: SizeConfig.scaleHeight(30)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool otpSent = false;
  bool loading = false;

  // Replace with your actual API base URL
  final String apiBase = 'http://192.168.1.6:5000/api';

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> sendOTP() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      showSnack("Please enter a phone number.");
      return;
    }

    setState(() => loading = true);

    final response = await http.post(
      Uri.parse('$apiBase/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone}),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      setState(() => otpSent = true);
      showSnack("OTP sent to $phone");
    } else {
      showSnack("Failed to send OTP: ${response.body}");
    }
  }

  Future<void> verifyOTP() async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showSnack("Please enter the OTP.");
      return;
    }

    setState(() => loading = true);
    print("Verifying OTP for $phone: $otp");
    final response = await http.post(
      Uri.parse('$apiBase/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone, 'code': otp}),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      showSnack("Phone number verified successfully!");
      // TODO: Navigate to the home page or next screen
    } else {
      showSnack("Verification failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Chikitsha Munshi Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            otpSent ? buildOTPInput() : buildPhoneInput(),
          ],
        ),
      ),
    );
  }

  Widget buildPhoneInput() {
   return Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const Text(
      "Enter your phone number",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 20),
    TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: "Phone Number",
        hintText: "+91XXXXXXXXXX",
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    const SizedBox(height: 24),
    SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : sendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Send OTP", style: TextStyle(fontSize: 16)),
      ),
    ),
  ],
);

  }

  Widget buildOTPInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: otpController,
          decoration: const InputDecoration(labelText: "Enter OTP"),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: loading ? null : verifyOTP,
          child: loading ? const CircularProgressIndicator() : const Text("Verify OTP"),
        )
      ],
    );
  }
}
