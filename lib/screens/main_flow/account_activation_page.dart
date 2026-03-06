import 'package:flutter/material.dart';

class AccountActivationPage extends StatefulWidget {
  final Map<String, dynamic>? initialRiderInfo;

  const AccountActivationPage({super.key, this.initialRiderInfo});

  @override
  State<AccountActivationPage> createState() => _AccountActivationPageState();
}

class _AccountActivationPageState extends State<AccountActivationPage> {
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

  bool _isSubmitting = false;
  String? _address;
  double? _addressLat;
  double? _addressLng;

  bool get _isEditMode => widget.initialRiderInfo != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialRiderInfo != null) {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
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
              const SizedBox(height: 8),
              _buildSectionTitle('Vehicle Information'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Name & Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your vehicle model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plateNoController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _driversLicenseNoController,
                decoration: const InputDecoration(
                  labelText: 'Driver\'s License Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your driver\'s license number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Address'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State / Province',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your state or province';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your primary address line';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Government IDs'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tinNoController,
                decoration: const InputDecoration(
                  labelText: 'TIN Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your TIN number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sssNoController,
                decoration: const InputDecoration(
                  labelText: 'SSS Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your SSS number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting
                        ? const Color(0xFF5D8AA8).withValues(alpha: 0.7)
                        : const Color(0xFF5D8AA8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5D8AA8),
      ),
    );
  }
}
