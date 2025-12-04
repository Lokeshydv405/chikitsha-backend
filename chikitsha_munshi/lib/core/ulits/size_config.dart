import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  // Horizontal scale based on width
  static double scaleWidth(double inputWidth) {
    // Reference width = 375.0 (iPhone 11/12)
    return (inputWidth / 375.0) * screenWidth;
  }

  // Vertical scale based on height
  static double scaleHeight(double inputHeight) {
    // Reference height = 812.0 (iPhone 11/12)
    return (inputHeight / 812.0) * screenHeight;
  }

  // Scaled font size
  static double scaleText(double fontSize) {
    return scaleWidth(fontSize); // typically use width for fonts
  }
}
