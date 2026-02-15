// FILE: lib/screens/main_flow/account_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/cards/info_row.dart';
import '../../widgets/cards/settings_tile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Mock data for design only
  final String _mockFirstName = 'John';
  final String _mockLastName = 'Doe';
  final String _mockEmail = 'john.doe@example.com';
  final String _mockMobileNo = '09123456789';
  final String _mockUserId = 'USR12345';
  final String _mockRiderId = 'RDR67890';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),

        // View Location Button
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 160,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Map page would open here (Demo)'),
                    backgroundColor: Color(0xFF5D8AA8),
                  ),
                );
              },
              icon: const Icon(Icons.map, size: 16),
              label: const Text(
                'View Location',
                style: TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D8AA8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Profile Avatar
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF5D8AA8),
                      const Color(0xFF5D8AA8).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D8AA8).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                '$_mockFirstName $_mockLastName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D8AA8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _mockEmail,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Personal Information Card
        InfoCard(
          title: 'Personal Information',
          icon: Icons.person_outline,
          children: [
            InfoRow(label: 'First Name', value: _mockFirstName),
            InfoRow(label: 'Last Name', value: _mockLastName),
            InfoRow(label: 'Email', value: _mockEmail),
            InfoRow(label: 'Mobile Number', value: _mockMobileNo),
            InfoRow(label: 'User ID', value: _mockUserId),
            InfoRow(label: 'Rider ID', value: _mockRiderId),
          ],
        ),

        const SizedBox(height: 16),

        // Account Settings Card
        InfoCard(
          title: 'Account Settings',
          icon: Icons.settings,
          children: [
            SettingsTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit Profile screen would open here (Demo)'),
                    backgroundColor: Color(0xFF5D8AA8),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Change Password screen would open here (Demo)',
                    ),
                    backgroundColor: Color(0xFF5D8AA8),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Activate Account Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D8AA8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account Activation page would open here (Demo)',
                  ),
                  backgroundColor: Color(0xFF5D8AA8),
                ),
              );
            },
            child: const Text(
              'Activate your Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.red, width: 1.5),
              elevation: 0,
            ),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // App Version
        Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully (Demo)'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
