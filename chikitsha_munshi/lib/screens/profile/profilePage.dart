import 'package:chikitsha_munshi/screens/profile/widgets/infoTiles.dart';
import 'package:chikitsha_munshi/screens/profile/widgets/profileHeader.dart';
import 'package:chikitsha_munshi/screens/profile/widgets/sectionTile.dart';
import 'package:flutter/material.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              name: "Lokesh Yadav",
              email: "lokeshydv2604@gmail.com",
              profileImage: 'assets/profile_avatar.png',
              walletAmount: "1000",
            ),
            // CorporateVerificationCard(),
            SectionTitle("Your Information"),
            InfoTile(
              title: "My Wallet",
              subtitle: "Check your promo and wallet cash balance",
              onTap: () {},
            ),
            InfoTile(
              title: "Bookings",
              subtitle: "Check your booking status and previous reports",
              onTap: () {
                Navigator.pushNamed(context, '/bookinglist');
              },
            ),
            InfoTile(
              title: "Cart",
              subtitle: "Check your cart items",
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
            ), 
            InfoTile(
              title: "Address",
              subtitle: "Check your addresses",
              onTap: () {
                Navigator.pushNamed(context, '/address');
              },
            ),
            InfoTile(
              title: "Health Corner",
              subtitle: "Check your health score",
              onTap: () {
                Navigator.pushNamed(context, '/heathtools');
              },
            ),
            InfoTile(
              title: "Family",
              subtitle: "Check your family members",
              onTap: () {
                Navigator.pushNamed(context, '/family');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 16),
              child: ElevatedButton.icon(
                onPressed: () => {},
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

