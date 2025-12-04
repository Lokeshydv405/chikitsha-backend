import 'package:flutter/material.dart';

import '../EditProfilePage.dart';
class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String profileImage;
  final String walletAmount;

  const ProfileHeader({
    required this.name,
    required this.email,
    required this.profileImage,
    required this.walletAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, $name!', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(email, style: theme.textTheme.bodyMedium),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Wallet Balance : ', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black)),
                    Text('₹$walletAmount', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold,color: Colors.black)),
                    SizedBox(width: 4),
                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  ],
                ),
              )
            ],
          ),
        ),
        Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue.shade100,
              // backgroundImage: AssetImage(profileImage),
            ),
            TextButton(
              onPressed: () {
                // Navigate to edit page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
              child: Text("Edit Profile", style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
      ],
    );
  }
}
