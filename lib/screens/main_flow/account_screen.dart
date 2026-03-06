import 'package:flutter/material.dart';
import '../../services/account/account_service.dart';
import '../../services/database/user_session_db.dart';
import '../../services/database/rider_orders_db.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/cards/info_row.dart';
import '../../widgets/cards/settings_tile.dart';
import '../location/map_page.dart';
import 'account_activation_page.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _session;
  Map<String, dynamic>? _riderInfo;
  bool _loadingRiderInfo = true;
  String? _riderInfoError;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _loadRiderInfo();
  }

  Future<void> _loadSession() async {
    final session = await UserSessionDB.getSession();
    if (!mounted) return;
    setState(() {
      _session = session != null ? Map<String, dynamic>.from(session) : null;
    });
  }

  Future<void> _loadRiderInfo() async {
    setState(() {
      _loadingRiderInfo = true;
      _riderInfoError = null;
    });

    try {
      final riderInfo = await AccountService.getRiderInfo();
      if (mounted) {
        setState(() {
          _riderInfo = riderInfo;
          _loadingRiderInfo = false;
          _riderInfoError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRiderInfo = false;
          _riderInfoError = e.toString();
        });
      }
    }
  }

  String _getFullName() {
    return _riderInfo?['Name']?.toString() ??
        '${_session?['firstname'] ?? ''} ${_session?['lastname'] ?? ''}'.trim();
  }

  String _getEmail() {
    return _session?['email']?.toString() ?? '';
  }

  String _getMobile() {
    return _riderInfo?['MobileNo']?.toString() ??
        _session?['mobile_no']?.toString() ??
        '';
  }

  String _getUserId() {
    return _session?['user_id']?.toString() ?? '';
  }

  String _getRiderId() {
    return _session?['rider_id']?.toString() ?? '';
  }

  String _getStreetAddress() {
    return AccountService.formatAddress(_riderInfo);
  }

  bool _isAccountActivated() {
    return AccountService.isAccountActivated(_riderInfo);
  }

  String _getProfileImageUrl() {
    final path = _riderInfo?['ProfilePic']?.toString();
    return AccountService.getProfileImageUrl(path);
  }

  Widget _buildProfileAvatar() {
    final url = _getProfileImageUrl();
    if (url.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFF5D8AA8),
        child: Icon(Icons.person, size: 50, color: Colors.white),
      );
    }
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }

  Widget _buildStatusChip() {
    final activated = _isAccountActivated();
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activated ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activated ? Colors.green : Colors.orange,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activated ? Icons.check_circle : Icons.pending,
              size: 18,
              color: activated ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              activated ? 'Account activated' : 'Account not activated',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: activated
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _getFullName();
    final email = _getEmail();
    final mobile = _getMobile();
    final userId = _getUserId();
    final riderId = _getRiderId();
    final streetAddress = _getStreetAddress();

    return RefreshIndicator(
      onRefresh: _loadRiderInfo,
      child: ListView(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage()),
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
                _buildProfileAvatar(),
                const SizedBox(height: 16),
                Text(
                  name.isEmpty ? 'Rider' : name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D8AA8),
                  ),
                ),
                const SizedBox(height: 8),
                if (email.isNotEmpty)
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
                      email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Status Chip
          _buildStatusChip(),

          const SizedBox(height: 20),

          if (_loadingRiderInfo)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFF5D8AA8)),
              ),
            )
          else if (_riderInfoError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _riderInfoError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadRiderInfo,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Account Info Card
            InfoCard(
              title: 'Account Information',
              icon: Icons.person_outline,
              children: [
                if (userId.isNotEmpty) InfoRow(label: 'User ID', value: userId),
                if (riderId.isNotEmpty)
                  InfoRow(label: 'Rider ID', value: riderId),
                if (mobile.isNotEmpty) InfoRow(label: 'Mobile', value: mobile),
              ],
            ),

            const SizedBox(height: 16),

            // Rider Details Card
            if (_riderInfo != null) ...[
              InfoCard(
                title: 'Rider Details',
                icon: Icons.motorcycle,
                children: [
                  InfoRow(
                    label: 'Vehicle',
                    value: _riderInfo!['Vehicle']?.toString() ?? '—',
                  ),
                  InfoRow(
                    label: 'Plate No',
                    value: _riderInfo!['PlateNo']?.toString() ?? '—',
                  ),
                  InfoRow(
                    label: "Driver's License",
                    value: _riderInfo!['DriversLicenseNo']?.toString() ?? '—',
                  ),
                  InfoRow(
                    label: 'TIN',
                    value: _riderInfo!['TINNo']?.toString() ?? '—',
                  ),
                  InfoRow(
                    label: 'SSS',
                    value: _riderInfo!['SSS']?.toString() ?? '—',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Address Card
              InfoCard(
                title: 'Address',
                icon: Icons.location_on,
                children: [
                  InfoRow(label: 'Street', value: streetAddress),
                  InfoRow(
                    label: 'City',
                    value: _riderInfo!['City']?.toString() ?? '—',
                  ),
                  InfoRow(
                    label: 'State',
                    value: _riderInfo!['State']?.toString() ?? '—',
                  ),
                ],
              ),
            ],
          ],

          const SizedBox(height: 16),

          // Settings Card
          InfoCard(
            title: 'Settings',
            icon: Icons.settings,
            children: [
              SettingsTile(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AccountActivationPage(initialRiderInfo: _riderInfo),
                    ),
                  );
                  if (updated == true && mounted) {
                    _loadRiderInfo();
                  }
                },
              ),
              SettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change Password coming soon'),
                      backgroundColor: Color(0xFF5D8AA8),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Activate Account Button (if not activated)
          if (!_isAccountActivated())
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
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountActivationPage(),
                    ),
                  );
                  if (updated == true && mounted) {
                    _loadRiderInfo();
                  }
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
              onPressed: _showLogoutConfirmation,
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
      ),
    );
  }

  void _showLogoutConfirmation() {
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
              onPressed: () async {
                print('[DEBUG] Logout clicked');
                Navigator.pop(context); // Close confirmation dialog

                print('[DEBUG] Showing loading dialog');
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5D8AA8)),
                  ),
                );

                print('[DEBUG] Clearing session...');
                await UserSessionDB.clearSession();
                print('[DEBUG] Session cleared');

                print('[DEBUG] Clearing rider orders...');
                await RiderOrdersDB.clearAllData();
                print('[DEBUG] Rider orders cleared');

                if (mounted) {
                  print('[DEBUG] Closing loading dialog');
                  Navigator.pop(context); // Close loading dialog

                  print('[DEBUG] Navigating to root');
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
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
