import 'package:chikitsha_munshi/core/ulits/size_config.dart';
import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/core/utils/user_prefs.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _handleContinue(BuildContext context) async {
    final userId = await UserPrefs.getUserId();
    if (userId != null && userId != '0') {
      Navigator.pushReplacementNamed(context, '/main', arguments: userId);
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.scaleWidth(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Logo and Title Section
                    Column(
                      children: [
                        SizedBox(height: SizeConfig.scaleHeight(40)),

                        // Logo
                        Container(
                          width: SizeConfig.scaleWidth(80),
                          height: SizeConfig.scaleHeight(80),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.science,
                            size: SizeConfig.scaleHeight(40),
                            color: Colors.blue,
                          ),
                        ),

                        SizedBox(height: SizeConfig.scaleHeight(16)),

                        Text(
                          "CHIKITSHA MUNSHI",
                          style: TextStyle(
                            fontSize: SizeConfig.scaleText(20),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 1.5,
                          ),
                        ),

                        SizedBox(height: SizeConfig.scaleHeight(24)),

                        Text(
                          "Book Lab Tests\nin Seconds",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.scaleText(32),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.scaleHeight(40)),

                    // Features Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.scaleHeight(32),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          FeatureColumn(
                            image: 'assets/images/samplecollection.png',
                            title: "Home Sample Collection",
                          ),
                          FeatureColumn(
                            image: 'assets/images/instantreport.png',
                            title: "Instant Reports",
                          ),
                          FeatureColumn(
                            image: 'assets/images/certifiedlabs.png',
                            title: "Certified Labs",
                          ),
                        ],
                      ),
                    ),
                    
                    // Continue Button

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.scaleWidth(20),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleContinue(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F7FFF),
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.scaleHeight(18),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Continue with Phone Number",
                            style: TextStyle(
                              fontSize: SizeConfig.scaleText(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.scaleHeight(20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureColumn extends StatelessWidget {
  final String title;
  final String image;

  const FeatureColumn({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.scaleWidth(100),
      height: SizeConfig.scaleHeight(140),
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.scaleWidth(6)),
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        // border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              image,
              width: SizeConfig.scaleWidth(100),
              height: SizeConfig.scaleHeight(80),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.scaleHeight(10),
              horizontal: SizeConfig.scaleWidth(8),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.scaleText(12),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
