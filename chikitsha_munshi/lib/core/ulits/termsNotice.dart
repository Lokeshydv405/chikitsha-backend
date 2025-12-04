import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/core/ulits/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsNotice extends StatelessWidget {
  const TermsNotice({super.key});
  void _openTerms() async {
  final uri = Uri.parse("https://www.google.com/search?q=mindheaven&oq=mind&gs_lcrp=EgZjaHJvbWUqBggBECMYJzIGCAAQRRg5MgYIARAjGCcyBggCECMYJzIVCAMQLhhDGK8BGMcBGLEDGIAEGIoFMg8IBBAAGEMYsQMYgAQYigUyDwgFEAAYQxixAxiABBiKBTIPCAYQABhDGLEDGIAEGIoFMgwIBxAAGEMYgAQYigUyEggIEC4YQxjHARjRAxiABBiKBTIPCAkQABhDGLEDGIAEGIoF0gEJNDA4OWowajE1qAIMsAIB8QW_htQ7cQHOCg&sourceid=chrome&ie=UTF-8");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

void _openPrivacy() async {
  final uri = Uri.parse("https://www.google.com/search?q=mindheaven&oq=mind&gs_lcrp=EgZjaHJvbWUqBggBECMYJzIGCAAQRRg5MgYIARAjGCcyBggCECMYJzIVCAMQLhhDGK8BGMcBGLEDGIAEGIoFMg8IBBAAGEMYsQMYgAQYigUyDwgFEAAYQxixAxiABBiKBTIPCAYQABhDGLEDGIAEGIoFMgwIBxAAGEMYgAQYigUyEggIEC4YQxjHARjRAxiABBiKBTIPCAkQABhDGLEDGIAEGIoF0gEJNDA4OWowajE1qAIMsAIB8QW_htQ7cQHOCg&sourceid=chrome&ie=UTF-8");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}


  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: SizeConfig.scaleWidth(13),
          color: Colors.grey.shade600,
        ),
        children: [
          const TextSpan(text: "By continuing, you agree to our "),
          TextSpan(
            text: "Terms of Service",
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _openTerms,
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _openPrivacy,
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }
}

