import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/account/account_service.dart';
import '../../services/network/network_service.dart';
import '../../services/database/user_session_db.dart';
import 'select_address_map_page.dart';

class AccountActivationScreen extends StatefulWidget {
  final Map<String, dynamic>? initialRiderInfo;

  const AccountActivationScreen({super.key, this.initialRiderInfo});

  @override
  State<AccountActivationScreen> createState() =>
      _AccountActivationScreenState();
}

class _AccountActivationScreenState extends State<AccountActivationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _plateNoController = TextEditingController();
  final TextEditingController _driversLicenseNoController =
      TextEditingController();
  final TextEditingController _tinNoController = TextEditingController();
  final TextEditingController _sssNoController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? _firstName;
  String? _lastName;
  String? _riderId;
  bool _isSubmitting = false;

  String? _address;
  double? _addressLat;
  double? _addressLng;

  String? _profilePicPath;
  String? _driversLicensePath;
  String? _plateNoPath;
  String? _selfieWithIdPath;
  String? _selfieWithPlateNoPath;
  String? _tinNoPath;
  String? _sssNoPath;

  bool get _isEditMode => widget.initialRiderInfo != null;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final session = await UserSessionDB.getSession();
    if (!mounted) return;

    setState(() {
      _firstName = session?['firstname']?.toString();
      _lastName = session?['lastname']?.toString();
      _riderId = session?['rider_id']?.toString();
    });

    if (_isEditMode) {
      _applyInitialRiderInfo(widget.initialRiderInfo!);
    }
  }

  void _applyInitialRiderInfo(Map<String, dynamic> info) {
    _vehicleModelController.text = (info['Vehicle']?.toString() ?? '').trim();
    _plateNoController.text = (info['PlateNo']?.toString() ?? '').trim();
    _driversLicenseNoController.text =
        (info['DriversLicenseNo']?.toString() ?? '').trim();
    _cityController.text = (info['City']?.toString() ?? '').trim();
    _stateController.text = (info['State']?.toString() ?? '').trim();
    _addressLine1Controller.text = (info['AddressLine1']?.toString() ?? '')
        .trim();
    _addressLine2Controller.text = (info['AddressLine2']?.toString() ?? '')
        .trim();
    _tinNoController.text = (info['TINNo']?.toString() ?? '').trim();
    _sssNoController.text = (info['SSS']?.toString() ?? '').trim();

    final lat = info['AddressLat'];
    final lng = info['AddressLng'];
    if (lat is num && lng is num) {
      _addressLat = lat.toDouble();
      _addressLng = lng.toDouble();
      _address =
          'Lat: ${_addressLat!.toStringAsFixed(5)}, Lng: ${_addressLng!.toStringAsFixed(5)}';
    }
  }

  @override
  void dispose() {
    _middleNameController.dispose();
    _vehicleModelController.dispose();
    _plateNoController.dispose();
    _driversLicenseNoController.dispose();
    _tinNoController.dispose();
    _sssNoController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(void Function(String path) onSelected) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      onSelected(image.path);
    });
  }

  Future<void> _openMapForAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectAddressMapPage()),
    );

    if (result is Map) {
      final lat = result['lat'];
      final lng = result['lng'];

      if (lat is num && lng is num) {
        setState(() {
          _addressLat = lat.toDouble();
          _addressLng = lng.toDouble();
          _address =
              result['address']?.toString() ??
              'Lat: ${_addressLat!.toStringAsFixed(5)}, Lng: ${_addressLng!.toStringAsFixed(5)}';

          final city = result['city']?.toString() ?? '';
          final state = result['state']?.toString() ?? '';
          final road = result['road']?.toString() ?? '';

          if (city.isNotEmpty) _cityController.text = city;
          if (state.isNotEmpty) _stateController.text = state;
          if (road.isNotEmpty) _addressLine1Controller.text = road;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check required fields for new activation
    if (!_isEditMode) {
      final missingUploads = <String>[];
      if (_profilePicPath == null) missingUploads.add('Profile Picture');
      if (_driversLicensePath == null) missingUploads.add('Driver\'s License');
      if (_plateNoPath == null) missingUploads.add('Plate Number Photo');
      if (_selfieWithIdPath == null) missingUploads.add('Selfie with ID');
      if (_selfieWithPlateNoPath == null) {
        missingUploads.add('Selfie with Plate Number');
      }
      if (_tinNoPath == null) missingUploads.add('TIN Document');
      if (_sssNoPath == null) missingUploads.add('SSS Document');

      if (_addressLat == null || _addressLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your address on the map.'),
          ),
        );
        return;
      }

      if (missingUploads.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please upload the following: ${missingUploads.join(', ')}',
            ),
          ),
        );
        return;
      }
    }

    final hasConnection = await NetworkService.hasInternetConnection();
    if (!hasConnection) {
      NetworkService.showNetworkErrorSnackBar(context);
      return;
    }

    if (_riderId == null || _riderId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to find Rider ID. Please log in again.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call for now
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Profile updated successfully!'
                : 'Account activated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Profile' : 'Activate your Account'),
        backgroundColor: const Color(0xFF5D8AA8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_firstName != null || _lastName != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rider Information',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('${_firstName ?? ''} ${_lastName ?? ''}'),
                        if (_riderId != null) Text('Rider ID: $_riderId'),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              _buildSectionTitle('Vehicle Information'),
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Name & Model',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plateNoController,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _driversLicenseNoController,
                decoration: const InputDecoration(
                  labelText: 'Driver\'s License Number',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Address'),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State / Province',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (optional)',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.map),
                title: Text(_address ?? 'No address selected'),
                subtitle: const Text('Tap to select on map'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openMapForAddress,
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Required Documents'),
              _buildImageTile(
                'Profile Picture',
                _profilePicPath,
                (p) => _profilePicPath = p,
              ),
              _buildImageTile(
                'Driver\'s License',
                _driversLicensePath,
                (p) => _driversLicensePath = p,
              ),
              _buildImageTile(
                'Plate Number Photo',
                _plateNoPath,
                (p) => _plateNoPath = p,
              ),
              _buildImageTile(
                'Selfie with ID',
                _selfieWithIdPath,
                (p) => _selfieWithIdPath = p,
              ),
              _buildImageTile(
                'Selfie with Plate No.',
                _selfieWithPlateNoPath,
                (p) => _selfieWithPlateNoPath = p,
              ),
              _buildImageTile(
                'TIN Document',
                _tinNoPath,
                (p) => _tinNoPath = p,
              ),
              _buildImageTile(
                'SSS Document',
                _sssNoPath,
                (p) => _sssNoPath = p,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode
                              ? 'Update Profile'
                              : 'Submit for Verification',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageTile(
    String label,
    String? path,
    Function(String) onSelected,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.image),
        title: Text(label),
        subtitle: Text(
          path ?? 'No file selected',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.upload_file),
        onTap: () => _pickImage(onSelected),
      ),
    );
  }
}
